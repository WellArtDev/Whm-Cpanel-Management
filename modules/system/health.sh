#!/usr/bin/env bash

wcp_health_check() {
    clear 2>/dev/null || true
    printf '=== WHMCPANEL HEALTH CHECK ===\n\n'
    wcp_detect_os; wcp_detect_cpanel
    printf '%-24s %s\n' "OS" "${WCP_OS_NAME:-unknown}"
    printf '%-24s %s\n' "cPanel/WHM" "$([[ $WCP_CPANEL == 1 ]] && echo DETECTED || echo NOT DETECTED)"
    printf '%-24s %s\n' "CPU" "$(nproc 2>/dev/null || echo '?') cores"
    printf '%-24s %s\n' "Load" "$(cut -d' ' -f1-3 /proc/loadavg 2>/dev/null || uptime)"
    printf '%-24s %s\n' "Memory" "$(free -h 2>/dev/null | awk '/^Mem:/ {print $3 " / " $2}' || echo '?')"
    printf '%-24s %s\n' "Swap" "$(free -h 2>/dev/null | awk '/^Swap:/ {print $3 " / " $2}' || echo '?')"
    printf '%-24s %s\n' "Root disk" "$(df -hP / 2>/dev/null | awk 'NR==2 {print $5 " used (" $3 "/" $2 ")"}')"
    printf '%-24s %s\n' "Root inodes" "$(df -Pi / 2>/dev/null | awk 'NR==2 {print $5 " used"}')"
    printf '\nServices:\n'
    local services=(sshd httpd apache2 nginx mysql mariadb exim dovecot named cpanel)
    local s
    for s in "${services[@]}"; do
        if [[ "$s" == "cpanel" && -n "$WCP_WHMAPI" ]]; then
            printf '  %-18s %s\n' "$s" "API available"
        elif wcp_service_status "$s" 2>/dev/null; then
            printf '  %-18s %s\n' "$s" "OK"
        fi
    done
}

wcp_health_score() {
    local score=100 used inodes
    used="$(df -P / 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5);print $5+0}')"
    inodes="$(df -Pi / 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5);print $5+0}')"
    (( used >= WCP_DISK_CRIT )) && ((score-=25))
    (( used >= WCP_DISK_WARN && used < WCP_DISK_CRIT )) && ((score-=10))
    (( inodes >= WCP_INODE_CRIT )) && ((score-=20))
    (( inodes >= WCP_INODE_WARN && inodes < WCP_INODE_CRIT )) && ((score-=10))
    [[ -n "$WCP_WHMAPI" ]] || ((score-=10))
    (( score < 0 )) && score=0
    printf 'Health score: %s/100\n' "$score"
}
