#!/usr/bin/env bash

wcp_menu() {
    while true; do
        clear 2>/dev/null || true
        printf '%s\n' "=============================================="
        printf '   %s v%s\n' "$WCP_APP_NAME" "$WCP_VERSION"
        printf '%s\n' "=============================================="
        printf '%s\n' \
          " 1. Server Health" \
          " 2. OS / cPanel Profile" \
          " 3. Accounts" \
          " 4. Backup / Restore" \
          " 5. Mail Center" \
          " 6. DNS Manager" \
          " 7. SSL / AutoSSL" \
          " 8. Database" \
          " 9. Services" \
          "10. Security Audit" \
          "11. PHP Malware Heuristic Scan" \
          "12. Disk Analyzer" \
          "13. Maintenance" \
          "14. Cron Audit" \
          "15. Troubleshooter" \
          "16. Full Report" \
          "17. API / Token Audit" \
          "18. API Catalog / Usage" \
          "19. Plugins" \
          "20. Remote SSH Management" \
          "21. Diagnostics / Dry-Run Toggle" \
          "19. Diagnostics / Dry-Run Toggle" \
          " 0. Exit"
        printf '%s\n' "----------------------------------------------"
        read -r -p "Select: " choice
        case "$choice" in
            1) wcp_health_check; wcp_health_score; wcp_pause ;;
            2) wcp_os_profile; echo; wcp_cpanel_capabilities 2>/dev/null || true; wcp_pause ;;
            3) wcp_accounts_menu ;;
            4) wcp_backup_menu ;;
            5) wcp_mail_menu ;;
            6) wcp_dns_menu ;;
            7) wcp_ssl_menu ;;
            8) wcp_db_menu ;;
            9) wcp_services_list; wcp_pause ;;
            10) wcp_security_audit; wcp_pause ;;
            11) wcp_php_scan_home; wcp_pause ;;
            12) wcp_disk_analyzer; wcp_pause ;;
            13) wcp_maintenance_menu ;;
            14) wcp_cron_export; cat "$(ls -t "$WCP_REPORT_DIR"/crontabs-*.txt 2>/dev/null | head -1)" 2>/dev/null; wcp_pause ;;
            15) wcp_troubleshoot_menu ;;
            16) wcp_generate_full_report; wcp_pause ;;
            17) wcp_api_token_audit; wcp_pause ;;
            18) wcp_api_catalog; wcp_api_usage; wcp_pause ;;
            19) wcp_plugins_list; wcp_pause ;;
            20) wcp_remote_menu ;;
            21) wcp_diagnostics_menu ;;
            0) return 0 ;;
            *) wcp_warn "Invalid choice."; sleep 1 ;;
        esac
    done
}

wcp_accounts_menu() {
    while true; do
        printf '\nAccounts: 1 List 2 Info 3 Suspend 4 Unsuspend 5 Terminate 6 Disk 0 Back\n'
        read -r -p "Select: " c
        case "$c" in
            1) wcp_accounts_list ;;
            2) wcp_accounts_info ;;
            3) wcp_accounts_suspend ;;
            4) wcp_accounts_unsuspend ;;
            5) wcp_accounts_terminate ;;
            6) wcp_accounts_disk_usage ;;
            0) return ;;
        esac
        wcp_pause
    done
}

wcp_backup_menu() {
    while true; do
        printf '\nBackup: 1 Create 2 Restore 3 Status 0 Back\n'
        read -r -p "Select: " c
        case "$c" in
            1) wcp_backup_account ;;
            2) wcp_restore_account ;;
            3) wcp_backup_status ;;
            0) return ;;
        esac
        wcp_pause
    done
}

wcp_mail_menu() {
    while true; do
        printf '\nMail: 1 Queue 2 Summary 3 Frozen cleanup 4 Deliverability 0 Back\n'
        read -r -p "Select: " c
        case "$c" in
            1) wcp_mail_queue ;;
            2) wcp_mail_queue_summary ;;
            3) wcp_mail_frozen_cleanup ;;
            4) wcp_mail_domain_check ;;
            0) return ;;
        esac
        wcp_pause
    done
}

wcp_dns_menu() {
    while true; do
        printf '\nDNS: 1 Zones 2 Zone 3 Export 0 Back\n'
        read -r -p "Select: " c
        case "$c" in
            1) wcp_dns_list_zones ;;
            2) wcp_dns_zone ;;
            3) wcp_dns_export ;;
            0) return ;;
        esac
        wcp_pause
    done
}

wcp_ssl_menu() {
    while true; do
        printf '\nSSL: 1 Check expiry 2 Run AutoSSL 0 Back\n'
        read -r -p "Select: " c
        case "$c" in
            1) wcp_ssl_expiry ;;
            2) wcp_ssl_autossl ;;
            0) return ;;
        esac
        wcp_pause
    done
}

wcp_db_menu() {
    while true; do
        printf '\nDatabase: 1 Status 2 Processlist 3 Size 0 Back\n'
        read -r -p "Select: " c
        case "$c" in
            1) wcp_db_status ;;
            2) wcp_db_processlist ;;
            3) wcp_db_size ;;
            0) return ;;
        esac
        wcp_pause
    done
}

wcp_maintenance_menu() {
    while true; do
        printf '\nMaintenance: 1 Analyze 2 Package cache 3 Rotated logs 0 Back\n'
        read -r -p "Select: " c
        case "$c" in
            1) wcp_maintenance_analyze ;;
            2) wcp_maintenance_cleanup_cache ;;
            3) wcp_maintenance_cleanup_logs ;;
            0) return ;;
        esac
        wcp_pause
    done
}

wcp_troubleshoot_menu() {
    while true; do
        printf '\nTroubleshoot: 1 Web 2 Mail 0 Back\n'
        read -r -p "Select: " c
        case "$c" in
            1) wcp_troubleshoot_web ;;
            2) wcp_troubleshoot_mail ;;
            0) return ;;
        esac
        wcp_pause
    done
}

wcp_diagnostics_menu() {
    printf '\nDry-run is currently %s\n' "$([[ $WCP_DRY_RUN == 1 ]] && echo ON || echo OFF)"
    read -r -p "Toggle dry-run? [y/N] " a
    if [[ "$a" =~ ^[Yy]$ ]]; then
        if [[ "$WCP_DRY_RUN" == 1 ]]; then WCP_DRY_RUN=0; else WCP_DRY_RUN=1; fi
        wcp_ok "Dry-run: $([[ $WCP_DRY_RUN == 1 ]] && echo ON || echo OFF)"
    fi
}
