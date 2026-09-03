#!/usr/bin/env bash

wcp_troubleshoot_web() {
    local domain="$1"
    [[ -n "$domain" ]] || read -r -p "Domain: " domain
    wcp_validate_domain "$domain" || return 2
    printf '=== WEB TROUBLESHOOTER: %s ===\n' "$domain"
    if wcp_has dig; then
        printf '\nDNS:\n'; dig +short "$domain" A "$domain" AAAA 2>/dev/null || true
    fi
    printf '\nHTTP:\n'
    if wcp_has curl; then
        curl -k -sS -o /dev/null -w 'HTTP %{http_code}, remote=%{remote_ip}, time=%{time_total}s\n' --max-time 15 "https://$domain/" || true
    fi
    printf '\nLocal services:\n'
    wcp_services_list
    printf '\nRecent web errors:\n'
    for f in /usr/local/cpanel/logs/error_log /var/log/httpd/error_log /var/log/apache2/error.log; do
        [[ -f "$f" ]] && { echo "--- $f"; tail -50 "$f"; }
    done
}

wcp_troubleshoot_mail() {
    printf '=== MAIL TROUBLESHOOTER ===\n'
    wcp_mail_queue_summary
    wcp_mail_tracking_hint
    for f in /var/log/exim_mainlog /var/log/exim_rejectlog /var/log/exim_paniclog; do
        [[ -f "$f" ]] && { echo "--- $f"; tail -30 "$f"; }
    done
}
