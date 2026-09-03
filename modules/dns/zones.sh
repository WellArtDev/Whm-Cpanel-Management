#!/usr/bin/env bash

wcp_dns_list_zones() {
    wcp_cpanel_assert || return
    wcp_whmapi listzones
}

wcp_dns_zone() {
    local domain="$1"
    [[ -n "$domain" ]] || read -r -p "Domain: " domain
    wcp_validate_domain "$domain" || { wcp_error "Invalid domain."; return 2; }
    wcp_whmapi dumpzone "domain=$domain"
}

wcp_dns_export() {
    local domain="$1" out="$2"
    [[ -n "$domain" ]] || read -r -p "Domain: " domain
    wcp_validate_domain "$domain" || return 2
    out="${out:-$WCP_REPORT_DIR/$domain-zone.txt}"
    wcp_whmapi dumpzone "domain=$domain" > "$out"
    chmod 600 "$out"
    wcp_ok "Saved $out"
}
