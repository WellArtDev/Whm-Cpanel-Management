#!/usr/bin/env bash
# =============================================================================
# WhmCpanel Management v9.2.0
# Modular WHM/cPanel administration toolkit
# =============================================================================

set -o pipefail

BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
source "$BASE_DIR/config/defaults.conf"
# shellcheck disable=SC1091
source "$BASE_DIR/lib/core.sh"
source "$BASE_DIR/lib/os.sh"
source "$BASE_DIR/lib/cpanel.sh"
source "$BASE_DIR/lib/validation.sh"
source "$BASE_DIR/lib/command.sh"
source "$BASE_DIR/lib/logging.sh"
source "$BASE_DIR/lib/ssh.sh"

while IFS= read -r -d '' file; do
    # shellcheck disable=SC1090
    source "$file"
done < <(find "$BASE_DIR/modules" -type f -name '*.sh' -print0 | sort -z)

source "$BASE_DIR/menus/main.sh"

wcp_main() {
    wcp_require_root || return 1
    wcp_init_state
    wcp_detect_os
    wcp_detect_cpanel
    wcp_ssh_init

    if [[ "$1" == "--dry-run" ]]; then WCP_DRY_RUN=1; shift; fi
    if [[ "$1" == "--yes" ]]; then WCP_ASSUME_YES=1; shift; fi

    case "${1:-menu}" in
        menu) wcp_menu ;;
        health) wcp_health_check; wcp_health_score ;;
        profile) wcp_os_profile; wcp_cpanel_capabilities 2>/dev/null || true ;;
        audit) wcp_security_audit ;;
        disk) wcp_disk_analyzer ;;
        report) wcp_generate_full_report ;;
        services) wcp_services_list ;;
        accounts) wcp_accounts_list ;;
        mail) wcp_mail_queue_summary ;;
        dns) wcp_dns_list_zones ;;
        remote) wcp_remote_cli "${@:2}" ;;
        *)
            wcp_error "Unknown command: $1"
            printf 'Commands: menu health profile audit disk report services accounts mail dns remote\n'
            return 2
            ;;
    esac
}

wcp_main "$@"
