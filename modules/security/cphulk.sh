#!/usr/bin/env bash

wcp_cphulk_status() {
    wcp_cpanel_assert || return
    if [[ -n "$WCP_WHMAPI" ]]; then
        wcp_whmapi cphulk_status 2>/dev/null || wcp_warn "cPHulk API function unavailable on this version."
    fi
    if [[ -x /usr/local/cpanel/bin/cphulkd ]]; then
        /usr/local/cpanel/bin/cphulkd --status 2>/dev/null || true
    fi
}

wcp_cphulk_logs() {
    find /usr/local/cpanel/logs -maxdepth 1 -type f -iname '*cphulk*' -print 2>/dev/null
}
