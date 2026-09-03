#!/usr/bin/env bash

wcp_accounts_list() {
    wcp_cpanel_assert || return
    wcp_whmapi listaccts
}

wcp_accounts_info() {
    local user="$1"
    [[ -n "$user" ]] || read -r -p "cPanel user: " user
    wcp_validate_account "$user" || { wcp_error "Invalid account."; return 2; }
    wcp_whmapi accountsummary "user=$user"
}

wcp_accounts_suspend() {
    local user="$1"
    [[ -n "$user" ]] || read -r -p "cPanel user: " user
    wcp_validate_account "$user" || return 2
    wcp_confirm "Suspend account '$user'?" || return 0
    wcp_whmapi suspendacct "user=$user"
}

wcp_accounts_unsuspend() {
    local user="$1"
    [[ -n "$user" ]] || read -r -p "cPanel user: " user
    wcp_validate_account "$user" || return 2
    wcp_confirm "Unsuspend account '$user'?" || return 0
    wcp_whmapi unsuspendacct "user=$user"
}

wcp_accounts_terminate() {
    local user="$1"
    [[ -n "$user" ]] || read -r -p "cPanel user: " user
    wcp_validate_account "$user" || return 2
    wcp_warn "DESTRUCTIVE: account termination removes hosting data."
    wcp_confirm_exact "$user" || { wcp_warn "Confirmation failed."; return 1; }
    wcp_whmapi removeacct "user=$user"
}

wcp_accounts_disk_usage() {
    local user="$1"
    [[ -n "$user" ]] || read -r -p "cPanel user: " user
    wcp_validate_account "$user" || return 2
    du -sh -- "/home/$user" 2>/dev/null || true
}
