#!/usr/bin/env bash

wcp_maintenance_analyze() {
    printf '=== MAINTENANCE ANALYSIS ===\n'
    wcp_detect_os
    local root_used inode_used
    root_used="$(df -P / | awk 'NR==2 {print $5}')"
    inode_used="$(df -Pi / | awk 'NR==2 {print $5}')"
    printf 'Disk:   %s\n' "$root_used"
    printf 'Inodes: %s\n' "$inode_used"
    printf '\nPackage cache:\n'
    case "$WCP_PKG_MGR" in
        dnf|yum) du -sh /var/cache/dnf /var/cache/yum 2>/dev/null || true ;;
        apt-get) du -sh /var/cache/apt 2>/dev/null || true ;;
    esac
    printf '\nLarge log directories:\n'
    du -xhd1 /var/log /usr/local/cpanel/logs 2>/dev/null | sort -h | tail -20 || true
}

wcp_maintenance_cleanup_cache() {
    wcp_detect_os
    wcp_os_assert_supported || return
    wcp_confirm "Clean package-manager cache?" || { wcp_warn "Cancelled."; return 0; }
    wcp_pkg_clean
}

wcp_maintenance_cleanup_logs() {
    wcp_warn "This action must not destroy forensic evidence."
    wcp_warn "Only compressible rotated logs are considered; active logs are untouched."
    local target
    target="/var/log"
    find "$target" -xdev -type f \( -name '*.log.*.gz' -o -name '*.old.gz' \) -mtime +30 -print 2>/dev/null | head -200
    wcp_confirm "Delete only the displayed rotated logs older than 30 days?" || return 0
    [[ "$WCP_DRY_RUN" == "1" ]] && return 0
    find "$target" -xdev -type f \( -name '*.log.*.gz' -o -name '*.old.gz' \) -mtime +30 -delete 2>/dev/null || true
}
