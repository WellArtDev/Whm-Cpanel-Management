#!/usr/bin/env bash

wcp_validate_ipv4_cidr() {
    local input="$1" ip prefix octet
    [[ "$input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?$ ]] || return 1
    ip="${input%%/*}"
    IFS=. read -r -a octets <<< "$ip"
    for octet in "${octets[@]}"; do ((octet >= 0 && octet <= 255)) || return 1; done
    if [[ "$input" == */* ]]; then
        prefix="${input##*/}"
        ((prefix >= 0 && prefix <= 32)) || return 1
    fi
}

wcp_validate_ipv6_cidr() {
    local input="$1" addr prefix
    [[ "$input" == */* ]] && { addr="${input%%/*}"; prefix="${input##*/}"; } || { addr="$input"; prefix="128"; }
    [[ "$prefix" =~ ^[0-9]{1,3}$ ]] && ((prefix >= 0 && prefix <= 128)) || return 1
    [[ "$addr" == *:* ]] || return 1
    wcp_has python3 || return 1
    python3 - "$addr/$prefix" <<'PY'
import ipaddress, sys
try: ipaddress.ip_network(sys.argv[1], strict=False)
except ValueError: raise SystemExit(1)
PY
}

wcp_validate_ip_cidr() {
    wcp_validate_ipv4_cidr "$1" || wcp_validate_ipv6_cidr "$1"
}

wcp_validate_port() { [[ "$1" =~ ^[0-9]+$ ]] && ((10#$1 >= 1 && 10#$1 <= 65535)); }

wcp_validate_account() { wcp_safe_user "$1"; }

wcp_validate_domain() { wcp_safe_domain "$1"; }
