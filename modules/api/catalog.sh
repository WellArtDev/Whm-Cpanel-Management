#!/usr/bin/env bash

wcp_api_catalog() {
    wcp_cpanel_assert || return
    printf '=== WHM API 1 CATALOG ===\n'
    if [[ -n "$WCP_WHMAPI" ]]; then
        "$WCP_WHMAPI" --output=json applist 2>/dev/null | head -c 12000
        printf '\n'
    fi
}

wcp_api_usage() {
    wcp_cpanel_assert || return
    printf '=== API USAGE / REGISTERED CALLS ===\n'
    printf '\nWHM API calls:\n'
    wcp_whmapi get_api_calls 2>/dev/null || true
    printf '\nWHM API pages:\n'
    wcp_whmapi get_api_pages 2>/dev/null || true
}

wcp_api_auth_guidance() {
    cat <<'EOF'
=== API AUTHENTICATION ===

Preferred:
  WHM API 1 + API token over HTTPS
  Authorization: whm username:token

WHM HTTPS API:
  2087 secure
  2086 insecure

cPanel HTTPS API/UAPI:
  2083 secure
  2082 insecure

Do not store API tokens in this repository or print token values into logs.
Legacy Remote Access Key / access hash is deprecated; prefer API tokens.
EOF
}

wcp_api_endpoint_check() {
    local host="$1"
    [[ -n "$host" ]] || read -r -p "WHM hostname/IP: " host
    [[ "$host" != *[!A-Za-z0-9.:-]* ]] || { wcp_error "Invalid host."; return 2; }
    wcp_require_bin curl || return
    printf 'Checking HTTPS WHM endpoint: https://%s:2087/\n' "$host"
    curl -k -sS -o /dev/null -w 'HTTP %{http_code}, time=%{time_total}s\n' \
        --connect-timeout 10 --max-time 20 "https://$host:2087/" || true
}
