#!/usr/bin/env bash

wcp_init_state() {
    umask 077
    mkdir -p "$WCP_LOG_DIR" "$WCP_REPORT_DIR" "$WCP_BACKUP_DIR" "$WCP_CACHE_DIR" "$WCP_CONFIG_DIR"
    chmod 700 "$WCP_STATE_DIR" "$WCP_LOG_DIR" "$WCP_REPORT_DIR" "$WCP_BACKUP_DIR" "$WCP_CACHE_DIR" "$WCP_CONFIG_DIR" 2>/dev/null || true
}

wcp_ts() { date '+%Y-%m-%d %H:%M:%S'; }
wcp_info() { printf '[INFO] %s\n' "$*"; }
wcp_ok() { printf '[ OK ] %s\n' "$*"; }
wcp_warn() { printf '[WARN] %s\n' "$*" >&2; }
wcp_error() { printf '[ERR ] %s\n' "$*" >&2; }
wcp_die() { wcp_error "$*"; return 1; }

wcp_log() {
    local level="$1"; shift
    printf '%s level=%s user=%s action=%q\n' "$(wcp_ts)" "$level" "${USER:-root}" "$*" >> "$WCP_LOG_DIR/actions.log"
}

wcp_report() {
    local name="$1"
    printf '%s\n' "$WCP_REPORT_DIR/$name"
}

wcp_pause() {
    [[ -t 0 ]] || return 0
    read -r -p "Press Enter to continue..." _
}

wcp_confirm() {
    local prompt="${1:-Continue?}"
    [[ "$WCP_ASSUME_YES" == "1" ]] && return 0
    [[ "$WCP_DRY_RUN" == "1" ]] && return 0
    local answer
    read -r -p "$prompt [y/N] " answer
    [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]
}

wcp_confirm_exact() {
    local expected="$1"
    [[ "$WCP_ASSUME_YES" == "1" ]] && return 0
    [[ "$WCP_DRY_RUN" == "1" ]] && return 0
    local answer
    read -r -p "Type '$expected' to confirm: " answer
    [[ "$answer" == "$expected" ]]
}

wcp_require_root() {
    [[ "${EUID:-99999}" -eq 0 ]] || { wcp_error "Run as root."; return 1; }
}

wcp_has() { command -v "$1" >/dev/null 2>&1; }

wcp_run() {
    if [[ "$#" -eq 0 ]]; then return 2; fi
    wcp_log INFO "command=$* dry_run=$WCP_DRY_RUN"
    if [[ "$WCP_DRY_RUN" == "1" ]]; then
        printf '[DRY-RUN]'; printf ' %q' "$@"; printf '\n'
        return 0
    fi
    "$@"
}

wcp_capture() {
    if [[ "$WCP_DRY_RUN" == "1" ]]; then
        printf '[DRY-RUN]'
        printf ' %q' "$@"
        printf '\n'
        return 0
    fi
    "$@"
}

wcp_atomic_write() {
    local target="$1"; shift
    local tmp
    tmp="$(mktemp "${target}.tmp.XXXXXX")" || return 1
    cat > "$tmp"
    chmod --reference="$target" "$tmp" 2>/dev/null || true
    mv -f -- "$tmp" "$target"
}

wcp_require_bin() {
    local missing=()
    local b
    for b in "$@"; do
        wcp_has "$b" || missing+=("$b")
    done
    if ((${#missing[@]})); then
        wcp_error "Missing binaries: ${missing[*]}"
        return 1
    fi
}

wcp_safe_user() {
    [[ "$1" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]{0,30}$ ]]
}

wcp_safe_domain() {
    local d="$1" label
    [[ -n "$d" && "$d" != .* && "$d" != *. && "$d" != *..* ]] || return 1
    [[ "$d" == *.* ]] || return 1
    [[ "$d" =~ ^[A-Za-z0-9.-]+$ ]] || return 1
    IFS=. read -r -a _wcp_labels <<< "$d"
    ((${#_wcp_labels[@]} >= 2)) || return 1
    for label in "${_wcp_labels[@]}"; do
        [[ "$label" =~ ^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$ ]] || return 1
    done
    ((${#d} <= 253))
}

wcp_safe_path() {
    local p="$1"
    [[ -n "$p" && "$p" != "/" && "$p" != *$'\n'* && "$p" != *$'\r'* ]]
}

wcp_json_escape() {
    local s="$1"
    s=${s//\\/\\\\}; s=${s//\"/\\\"}; s=${s//$'\n'/\\n}; s=${s//$'\r'/\\r}
    printf '%s' "$s"
}
