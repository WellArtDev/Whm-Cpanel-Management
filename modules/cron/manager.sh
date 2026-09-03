#!/usr/bin/env bash

wcp_cron_list_all() {
    printf '=== USER CRONTABS ===\n'
    if wcp_has crontab; then
        while IFS=: read -r user _ uid gid _ home shell; do
            [[ "$uid" =~ ^[0-9]+$ ]] || continue
            ((uid < 1000)) && continue
            printf '\n--- %s ---\n' "$user"
            crontab -u "$user" -l 2>/dev/null || true
        done < /etc/passwd
    fi
    printf '\n=== SYSTEM CRON ===\n'
    cat /etc/crontab 2>/dev/null || true
}

wcp_cron_export() {
    local out="$WCP_REPORT_DIR/crontabs-$(date +%Y%m%d-%H%M%S).txt"
    wcp_cron_list_all > "$out"
    chmod 600 "$out"
    wcp_ok "Saved $out"
}
