#!/usr/bin/env bash

wcp_services_list() {
    printf '=== SERVICE STATUS ===\n'
    if [[ -n "$WCP_WHMAPI" ]]; then
        wcp_whmapi servicestatus 2>/dev/null || true
        return
    fi
    local svc
    for svc in sshd httpd apache2 nginx php-fpm mysql mariadb exim dovecot named; do
        if wcp_service_status "$svc" 2>/dev/null; then printf '[ OK ] %s\n' "$svc"; fi
    done
}

wcp_services_restart() {
    local svc="$1"
    if [[ -z "$svc" ]]; then
        read -r -p "Service: " svc
    fi
    if [[ -n "$WCP_WHMAPI" ]]; then
        wcp_restart_cpanel_service "$svc"
    else
        case "$svc" in
            sshd|httpd|apache2|nginx|php-fpm|mysql|mariadb|exim|dovecot|named) wcp_service_restart "$svc" ;;
            *) wcp_error "Not allowlisted."; return 2 ;;
        esac
    fi
}
