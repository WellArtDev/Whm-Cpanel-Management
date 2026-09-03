#!/usr/bin/env bash

wcp_domains_list() {
    local user="$1"
    [[ -n "$user" ]] || read -r -p "cPanel user: " user
    wcp_validate_account "$user" || return 2
    wcp_uapi --user="$user" Domain list_domains
}

wcp_domains_ssl() {
    local user="$1"
    [[ -n "$user" ]] || read -r -p "cPanel user: " user
    wcp_validate_account "$user" || return 2
    wcp_uapi --user="$user" SSL list_ssl_capabilities
}
