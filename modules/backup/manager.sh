#!/usr/bin/env bash

wcp_backup_account() {
    local user="$1"
    [[ -n "$user" ]] || read -r -p "cPanel user: " user
    wcp_validate_account "$user" || return 2
    local out="$WCP_BACKUP_DIR/$user-$(date +%Y%m%d-%H%M%S)"
    wcp_mkdir_backup "$out"
    wcp_warn "Backup can consume significant disk space."
    wcp_confirm "Create account backup for '$user'?" || return 0
    wcp_cpanel_script pkgacct "$user" "$out"
}

wcp_mkdir_backup() {
    local p="$1"
    wcp_safe_path "$p" || return 2
    mkdir -p -- "$p"
    chmod 700 -- "$p"
}

wcp_restore_account() {
    local archive="$1"
    [[ -n "$archive" ]] || read -r -p "Backup path: " archive
    [[ -f "$archive" ]] || { wcp_error "Backup file not found."; return 1; }
    case "$archive" in /root/whmcpanel/backups/*) ;; *) wcp_error "Restore path must be under $WCP_BACKUP_DIR."; return 2;; esac
    wcp_warn "RESTORE modifies server/account state."
    wcp_confirm_exact "$(basename "$archive")" || return 1
    wcp_cpanel_script restorepkg "$archive"
}

wcp_backup_status() {
    if [[ -n "$WCP_WHMAPI" ]]; then
        wcp_whmapi backup_config_get 2>/dev/null || true
    fi
    find "$WCP_BACKUP_DIR" -maxdepth 2 -type f -printf '%TY-%Tm-%Td %TH:%TM %10s %p\n' 2>/dev/null | sort -r | head -100
}
