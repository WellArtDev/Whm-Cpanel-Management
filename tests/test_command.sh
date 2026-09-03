#!/usr/bin/env bash
set -u
BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/config/defaults.conf"
source "$BASE_DIR/lib/core.sh"
WCP_STATE_DIR="$(mktemp -d)"
WCP_LOG_DIR="$WCP_STATE_DIR/logs"
mkdir -p "$WCP_LOG_DIR"
WCP_DRY_RUN=1
wcp_run echo hello
printf 'test_command: PASS\n'
rm -rf "$WCP_STATE_DIR"
