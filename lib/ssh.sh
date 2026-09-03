#!/usr/bin/env bash

wcp_ssh_init() {
    mkdir -p "$WCP_SSH_CONFIG_DIR"
    chmod 700 "$WCP_SSH_CONFIG_DIR" 2>/dev/null || true
    if [[ ! -f "$WCP_SSH_SERVERS_FILE" ]]; then
        printf '# name|host|port|user|identity_file|jump_host\n' > "$WCP_SSH_SERVERS_FILE"
        chmod 600 "$WCP_SSH_SERVERS_FILE"
    fi
}

wcp_ssh_validate_name() { [[ "$1" =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,62}$ ]]; }
wcp_ssh_validate_host() { [[ "$1" =~ ^[A-Za-z0-9_.:-]+$ ]]; }
wcp_ssh_validate_port() { [[ "$1" =~ ^[0-9]+$ ]] && (( $1 >= 1 && $1 <= 65535 )); }

wcp_ssh_add_server() {
    local name host port user identity jump
    read -r -p 'Server name: ' name
    read -r -p 'Host/IP: ' host
    read -r -p "SSH port [$WCP_SSH_PORT]: " port; port="${port:-$WCP_SSH_PORT}"
    read -r -p 'SSH user [root]: ' user; user="${user:-root}"
    read -r -p 'Identity file [~/.ssh/id_ed25519]: ' identity; identity="${identity:-$HOME/.ssh/id_ed25519}"
    read -r -p 'Jump host (optional): ' jump
    wcp_ssh_validate_name "$name" || { wcp_error 'Invalid server name.'; return 1; }
    wcp_ssh_validate_host "$host" || { wcp_error 'Invalid host/IP.'; return 1; }
    wcp_ssh_validate_port "$port" || { wcp_error 'Invalid SSH port.'; return 1; }
    wcp_safe_user "$user" || { wcp_error 'Invalid SSH username.'; return 1; }
    [[ -n "$identity" ]] || identity='-'
    [[ -n "$jump" ]] && wcp_ssh_validate_host "$jump" || true
    grep -Fq "^${name}|" "$WCP_SSH_SERVERS_FILE" 2>/dev/null && { wcp_error "Server already exists: $name"; return 1; }
    printf '%s|%s|%s|%s|%s|%s\n' "$name" "$host" "$port" "$user" "$identity" "${jump:--}" >> "$WCP_SSH_SERVERS_FILE"
    chmod 600 "$WCP_SSH_SERVERS_FILE"
    wcp_log INFO "remote_server_add name=$name host=$host port=$port user=$user"
    wcp_ok "Added $name"
}

wcp_ssh_remove_server() {
    local name="$1" tmp
    wcp_ssh_validate_name "$name" || return 1
    grep -Fq "^${name}|" "$WCP_SSH_SERVERS_FILE" || { wcp_error "Unknown server: $name"; return 1; }
    wcp_confirm_exact "$name" || return 1
    tmp="$(mktemp)" || return 1
    awk -F'|' -v n="$name" '$1 != n' "$WCP_SSH_SERVERS_FILE" > "$tmp"
    mv -f "$tmp" "$WCP_SSH_SERVERS_FILE"; chmod 600 "$WCP_SSH_SERVERS_FILE"
    wcp_log INFO "remote_server_remove name=$name"
    wcp_ok "Removed $name"
}

wcp_ssh_get_server() {
    local name="$1"
    awk -F'|' -v n="$name" '$1 == n {print; exit}' "$WCP_SSH_SERVERS_FILE"
}

wcp_ssh_list_servers() {
    [[ -f "$WCP_SSH_SERVERS_FILE" ]] || { wcp_ssh_init; return; }
    printf '%-18s %-32s %-6s %-12s %s\n' NAME HOST PORT USER IDENTITY
    awk -F'|' '$0 !~ /^#/ && NF >= 5 {printf "%-18s %-32s %-6s %-12s %s\n",$1,$2,$3,$4,$5}' "$WCP_SSH_SERVERS_FILE"
}

wcp_ssh_build_opts() {
    printf '%s\n' \
      "-o" "BatchMode=yes" \
      "-o" "ConnectTimeout=$WCP_SSH_CONNECT_TIMEOUT" \
      "-o" "ConnectionAttempts=1" \
      "-o" "ServerAliveInterval=$WCP_SSH_KEEPALIVE" \
      "-o" "ServerAliveCountMax=$WCP_SSH_KEEPALIVE_COUNT" \
      "-o" "StrictHostKeyChecking=$WCP_SSH_HOSTKEY_POLICY" \
      "-o" "LogLevel=ERROR"
}

wcp_ssh_target() {
    local row="$1" host port user identity jump
    IFS='|' read -r _ host port user identity jump <<< "$row"
    [[ "$host" == *:* && "$host" != \[*\] ]] && host="[$host]"
    printf '%s' "$user@$host"
}

wcp_ssh_exec_row() {
    local row="$1" command="$2" timeout_s="${3:-$WCP_SSH_COMMAND_TIMEOUT}"
    local name host port user identity jump target opts=() rc
    IFS='|' read -r name host port user identity jump <<< "$row"
    target="$(wcp_ssh_target "$row")"
    mapfile -t opts < <(wcp_ssh_build_opts)
    [[ "$identity" == '-' || -z "$identity" ]] || opts+=("-i" "$identity")
    [[ "$port" =~ ^[0-9]+$ ]] && opts+=("-p" "$port")
    [[ "$jump" == '-' || -z "$jump" ]] || opts+=("-J" "$jump")
    wcp_log INFO "remote_exec server=$name target=$target command=$command"
    printf '[%s] %s\n' "$name" "$command"
    if [[ "$WCP_DRY_RUN" == '1' ]]; then
        printf '[DRY-RUN] ssh'; printf ' %q' "${opts[@]}" "$target" "$command"; printf '\n'
        return 0
    fi
    if wcp_has timeout; then
        timeout --signal=TERM --kill-after=5s "$timeout_s" ssh "${opts[@]}" "$target" -- "$command"
    else
        ssh "${opts[@]}" "$target" -- "$command"
    fi
    rc=$?
    wcp_log INFO "remote_exec_result server=$name rc=$rc"
    return "$rc"
}

wcp_ssh_test() {
    local name="$1" row
    row="$(wcp_ssh_get_server "$name")" || true
    [[ -n "$row" ]] || { wcp_error "Unknown server: $name"; return 1; }
    wcp_ssh_exec_row "$row" 'printf "REMOTE_OK\n"; uname -srm; test -x /usr/local/cpanel/bin/whmapi1 && echo CPANEL_API=YES || echo CPANEL_API=NO' 30
}

wcp_ssh_exec() {
    local name="$1"; shift
    local row command
    row="$(wcp_ssh_get_server "$name")" || true
    [[ -n "$row" ]] || { wcp_error "Unknown server: $name"; return 1; }
    (($#)) || { wcp_error 'Remote command required.'; return 2; }
    command="$*"
    wcp_ssh_exec_row "$row" "$command" "$WCP_SSH_COMMAND_TIMEOUT"
}

wcp_ssh_shell() {
    local name="$1" row host port user identity jump target opts=()
    row="$(wcp_ssh_get_server "$name")" || true
    [[ -n "$row" ]] || { wcp_error "Unknown server: $name"; return 1; }
    IFS='|' read -r name host port user identity jump <<< "$row"
    target="$(wcp_ssh_target "$row")"
    mapfile -t opts < <(wcp_ssh_build_opts)
    [[ "$identity" == '-' || -z "$identity" ]] || opts+=("-i" "$identity")
    opts+=("-p" "$port")
    [[ "$jump" == '-' || -z "$jump" ]] || opts+=("-J" "$jump")
    wcp_log INFO "remote_shell server=$name target=$target"
    [[ "$WCP_DRY_RUN" == '1' ]] && { printf '[DRY-RUN] ssh'; printf ' %q' "${opts[@]}" "$target"; printf '\n'; return 0; }
    ssh "${opts[@]}" "$target"
}

wcp_ssh_broadcast() {
    local command="$*" row name rc=0
    (($#)) || { wcp_error 'Broadcast command required.'; return 2; }
    while IFS= read -r row; do
        [[ -z "$row" || "$row" == \#* ]] && continue
        name="${row%%|*}"
        wcp_ssh_exec_row "$row" "$command" || rc=1
    done < "$WCP_SSH_SERVERS_FILE"
    return "$rc"
}

wcp_remote_os_profile() {
    local name="$1" row
    row="$(wcp_ssh_get_server "$name")" || true
    [[ -n "$row" ]] || { wcp_error "Unknown server: $name"; return 1; }
    wcp_ssh_exec_row "$row" 'set -eu; . /etc/os-release; printf "OS=%s\nVERSION=%s\n" "${PRETTY_NAME:-${NAME:-unknown}}" "${VERSION_ID:-unknown}"; command -v dnf >/dev/null 2>&1 && echo PKG=dnf || true; command -v apt-get >/dev/null 2>&1 && echo PKG=apt-get || true; command -v systemctl >/dev/null 2>&1 && echo SERVICE=systemd || true; test -x /usr/local/cpanel/bin/whmapi1 && echo CPANEL=YES || echo CPANEL=NO' 30
}
