#!/usr/bin/env bash
set -u
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/config/defaults.conf"
source "$ROOT/lib/core.sh"
source "$ROOT/lib/os.sh"
source "$ROOT/lib/cpanel.sh"
source "$ROOT/lib/validation.sh"
source "$ROOT/lib/command.sh"
source "$ROOT/lib/logging.sh"
source "$ROOT/lib/ssh.sh"
WCP_DRY_RUN=1
WCP_ASSUME_YES=1
wcp_ssh_validate_name server01 || exit 1
wcp_ssh_validate_host 2001:db8::1 || exit 1
wcp_ssh_validate_port 22 || exit 1
wcp_ssh_init
printf 'server01|127.0.0.1|22|root|-|-\n' > "$WCP_SSH_SERVERS_FILE"
wcp_ssh_exec server01 'echo test' >/tmp/wcp-ssh-test.out || exit 1
grep -q 'DRY-RUN' /tmp/wcp-ssh-test.out || exit 1
rm -f /tmp/wcp-ssh-test.out
printf 'test_ssh: PASS\n'
