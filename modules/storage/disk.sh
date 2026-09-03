#!/usr/bin/env bash

wcp_disk_analyzer() {
    printf '=== DISK ANALYZER ===\n'
    df -hP
    printf '\n=== INODE ANALYZER ===\n'
    df -iP
    printf '\n=== TOP /home USERS ===\n'
    if [[ -d /home ]]; then
        du -xhd1 /home 2>/dev/null | sort -h | tail -30
    fi
    printf '\n=== TOP LOG DIRECTORIES ===\n'
    du -xhd1 /var/log 2>/dev/null | sort -h | tail -20
}

wcp_large_files() {
    local path="${1:-/home}"
    wcp_safe_path "$path" || return 2
    printf 'Largest files under %s:\n' "$path"
    find "$path" -xdev -type f -size +500M -printf '%s\t%p\n' 2>/dev/null |
        sort -nr | head -100 | numfmt --field=1 --to=iec 2>/dev/null || true
}
