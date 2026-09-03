#!/usr/bin/env bash

wcp_mail_domain_check() {
    local domain="$1"
    [[ -n "$domain" ]] || read -r -p "Domain: " domain
    wcp_validate_domain "$domain" || { wcp_error "Invalid domain."; return 2; }
    printf 'DNS checks for %s\n\n' "$domain"
    if wcp_has dig; then
        printf 'A/AAAA:\n'; dig +short "$domain" A "$domain" AAAA 2>/dev/null || true
        printf '\nMX:\n'; dig +short "$domain" MX 2>/dev/null || true
        printf '\nTXT:\n'; dig +short "$domain" TXT 2>/dev/null || true
    else
        wcp_warn "dig not installed."
    fi
}
