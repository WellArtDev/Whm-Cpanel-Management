#!/usr/bin/env bash

wcp_audit() {
    local action="$1" result="$2"
    wcp_log AUDIT "action=$action result=$result"
}

wcp_make_report() {
    local prefix="${1:-report}"
    local path="$WCP_REPORT_DIR/${prefix}-$(date +%Y%m%d-%H%M%S).txt"
    printf '%s\n' "$path"
}
