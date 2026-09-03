#!/usr/bin/env bash
set -u
BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/config/defaults.conf"
source "$BASE_DIR/lib/core.sh"
source "$BASE_DIR/lib/os.sh"

wcp_detect_os
case "$WCP_OS_ID" in
  almalinux|cloudlinux|cloudlinux-server|rocky|ubuntu) [[ "$WCP_OS_SUPPORTED" == 1 ]] ;;
  *) [[ "$WCP_OS_SUPPORTED" == 0 ]] ;;
esac
printf 'test_os: PASS (%s)\n' "${WCP_OS_ID:-unknown}"
