#!/usr/bin/env bash

WCP_CPANEL=0
WCP_WHMAPI=""
WCP_UAPI=""
WCP_SCRIPTS_DIR="/scripts"

wcp_detect_cpanel() {
    WCP_CPANEL=0
    [[ -d /usr/local/cpanel || -x /usr/local/cpanel/bin/whmapi1 || -x /usr/local/cpanel/bin/uapi ]] && WCP_CPANEL=1
    if wcp_has whmapi1; then WCP_WHMAPI="$(command -v whmapi1)"
    elif [[ -x /usr/local/cpanel/bin/whmapi1 ]]; then WCP_WHMAPI="/usr/local/cpanel/bin/whmapi1"
    else WCP_WHMAPI=""
    fi
    if wcp_has uapi; then WCP_UAPI="$(command -v uapi)"
    elif [[ -x /usr/local/cpanel/bin/uapi ]]; then WCP_UAPI="/usr/local/cpanel/bin/uapi"
    else WCP_UAPI=""
    fi
}

wcp_cpanel_assert() {
    [[ "$WCP_CPANEL" == "1" ]] || { wcp_error "cPanel/WHM installation not detected."; return 1; }
}

# WHM API 1 command-line wrapper.
# cPanel documentation specifies whmapi1 and recommends API tokens for
# external HTTPS authentication. CloudLinux may require the full path.
wcp_whmapi() {
    wcp_cpanel_assert || return
    [[ -n "$WCP_WHMAPI" ]] || { wcp_error "whmapi1 not available."; return 1; }
    "$WCP_WHMAPI" --output=json "$@"
}

# UAPI command-line wrapper. WHM/root callers must specify the cPanel user.
wcp_uapi() {
    wcp_cpanel_assert || return
    [[ -n "$WCP_UAPI" ]] || { wcp_error "uapi not available."; return 1; }
    "$WCP_UAPI" --output=json "$@"
}

wcp_cpanel_script() {
    local script="$1"; shift
    [[ "$script" =~ ^[A-Za-z0-9._-]+$ ]] || { wcp_error "Invalid cPanel script name."; return 2; }
    local path="/usr/local/cpanel/scripts/$script"
    [[ -x "$path" ]] || path="/scripts/$script"
    [[ -x "$path" ]] || { wcp_error "cPanel script not found: $script"; return 1; }
    wcp_run "$path" "$@"
}

wcp_cpanel_capabilities() {
    wcp_cpanel_assert || return
    printf '%-28s %s\n' "WHM API 1" "$([[ -n "$WCP_WHMAPI" ]] && echo YES || echo NO)"
    printf '%-28s %s\n' "UAPI" "$([[ -n "$WCP_UAPI" ]] && echo YES || echo NO)"
    printf '%-28s %s\n' "/usr/local/cpanel" "$([[ -d /usr/local/cpanel ]] && echo YES || echo NO)"
    printf '%-28s %s\n' "CSF" "$([[ -x /usr/sbin/csf ]] && echo YES || echo NO)"
    printf '%-28s %s\n' "ClamAV" "$([[ -x /usr/bin/clamscan || -x /usr/local/cpanel/3rdparty/bin/clamscan ]] && echo YES || echo NO)"
}

wcp_whmapi_function_available() {
    local fn="$1"
    [[ "$fn" =~ ^[a-zA-Z0-9_]+$ ]] || return 2
    [[ -n "$WCP_WHMAPI" ]] || return 1
    "$WCP_WHMAPI" applist --output=json 2>/dev/null |
        grep -q "\"$fn\""
}

wcp_uapi_function_available() {
    local module="$1" fn="$2"
    [[ "$module" =~ ^[A-Za-z0-9_]+$ && "$fn" =~ ^[A-Za-z0-9_]+$ ]] || return 2
    [[ -n "$WCP_UAPI" ]] || return 1
    "$WCP_UAPI" --output=json "$module" "$fn" 2>/dev/null >/dev/null
}

wcp_whmapi_selftest() {
    wcp_cpanel_assert || return
    [[ -n "$WCP_WHMAPI" ]] || { wcp_error "WHM API 1 unavailable."; return 1; }
    printf 'Testing WHM API 1...\n'
    "$WCP_WHMAPI" --output=json applist >/dev/null 2>&1 &&
        wcp_ok "WHM API 1 reachable" ||
        { wcp_error "WHM API 1 self-test failed."; return 1; }
}

wcp_uapi_selftest() {
    wcp_cpanel_assert || return
    [[ -n "$WCP_UAPI" ]] || { wcp_error "UAPI unavailable."; return 1; }
    printf 'UAPI requires a cPanel account context for account-level calls.\n'
    printf 'Use: uapi --user=<cpanel-user> --output=json Module function\n'
}

wcp_whmapi_ok() {
    [[ -n "$WCP_WHMAPI" ]] && "$WCP_WHMAPI" --output=json "$1" >/dev/null 2>&1
}
