#!/usr/bin/env bash

wcp_command_exists() { command -v "$1" >/dev/null 2>&1 || [[ -x "$1" ]]; }

wcp_run_checked() {
    local label="$1"; shift
    wcp_info "$label"
    if wcp_run "$@"; then
        wcp_ok "$label"
        return 0
    fi
    wcp_error "$label failed"
    return 1
}

wcp_restart_cpanel_service() {
    local service="$1"
    wcp_cpanel_assert || return 1
    case "$service" in
        cpanel) service=cpsrvd ;;
        cpsrvd|httpd|exim|dovecot|named|cphulkd|mysql) ;;
        apache) service=httpd ;;
        *) wcp_error "Service not allowlisted: $service"; return 2 ;;
    esac
    wcp_whmapi restartservice "service=$service"
}

wcp_service_health() {
    local svc="$1"
    if wcp_service_status "$svc"; then printf 'PASS'; else printf 'FAIL'; fi
}
