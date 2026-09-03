#!/usr/bin/env bash
set -u
BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/config/defaults.conf"
source "$BASE_DIR/lib/core.sh"
source "$BASE_DIR/lib/validation.sh"

wcp_validate_ipv4_cidr 192.168.1.1/24
! wcp_validate_ipv4_cidr 999.1.1.1
wcp_validate_port 443
! wcp_validate_port 99999
wcp_validate_domain example.com
printf 'test_validation: PASS\n'
