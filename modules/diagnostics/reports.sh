#!/usr/bin/env bash

wcp_generate_full_report() {
    local out="$WCP_REPORT_DIR/full-audit-$(date +%Y%m%d-%H%M%S).txt"
    {
        echo "WhmCpanel Management v$WCP_VERSION"
        echo "Generated: $(wcp_ts)"
        echo
        wcp_os_profile
        echo
        wcp_cpanel_capabilities 2>/dev/null || true
        echo
        wcp_health_check
        echo
        wcp_health_score
        echo
        wcp_security_audit
        echo
        wcp_disk_analyzer
    } > "$out"
    chmod 600 "$out"
    wcp_ok "Report: $out"
}
