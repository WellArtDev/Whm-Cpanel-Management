#!/usr/bin/env bash

wcp_ssl_expiry() {
    local host="$1"
    [[ -n "$host" ]] || read -r -p "Hostname: " host
    wcp_validate_domain "$host" || { wcp_error "Invalid hostname."; return 2; }
    wcp_require_bin openssl || return
    local end epoch now days
    end="$(printf '' | openssl s_client -servername "$host" -connect "$host:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | sed 's/^notAfter=//')"
    [[ -n "$end" ]] || { wcp_error "Unable to read certificate."; return 1; }
    epoch="$(date -d "$end" +%s 2>/dev/null)" || { wcp_error "Unable to parse certificate date."; return 1; }
    now="$(date +%s)"
    days=$(( (epoch-now)/86400 ))
    printf '%s expires in %s days (%s)\n' "$host" "$days" "$end"
    (( days < WCP_SSL_CRIT_DAYS )) && return 2
    (( days < WCP_SSL_WARN_DAYS )) && return 3
}

wcp_ssl_autossl() {
    local user="$1"
    [[ -n "$user" ]] || read -r -p "cPanel user: " user
    wcp_validate_account "$user" || return 2
    wcp_uapi --user="$user" SSL start_autossl_check
}
