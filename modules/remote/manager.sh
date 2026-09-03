#!/usr/bin/env bash

wcp_remote_cli() {
    local action="${1:-menu}"; shift || true
    case "$action" in
        list) wcp_ssh_list_servers ;;
        add) wcp_ssh_add_server ;;
        remove) [[ $# -eq 1 ]] || { wcp_error 'Usage: remote remove NAME'; return 2; }; wcp_ssh_remove_server "$1" ;;
        test) [[ $# -eq 1 ]] || { wcp_error 'Usage: remote test NAME'; return 2; }; wcp_ssh_test "$1" ;;
        profile) [[ $# -eq 1 ]] || { wcp_error 'Usage: remote profile NAME'; return 2; }; wcp_remote_os_profile "$1" ;;
        exec) [[ $# -ge 2 ]] || { wcp_error 'Usage: remote exec NAME COMMAND...'; return 2; }; wcp_ssh_exec "$@" ;;
        shell) [[ $# -eq 1 ]] || { wcp_error 'Usage: remote shell NAME'; return 2; }; wcp_ssh_shell "$1" ;;
        broadcast) [[ $# -ge 1 ]] || { wcp_error 'Usage: remote broadcast COMMAND...'; return 2; }; wcp_ssh_broadcast "$@" ;;
        api) wcp_remote_api_cli "$@" ;;
        menu) wcp_remote_menu ;;
        *) wcp_error "Unknown remote action: $action"; printf 'Actions: list add remove test profile exec shell broadcast api menu\n'; return 2 ;;
    esac
}

wcp_remote_api_cli() {
    local name="$1" api="$2"; shift 2 || true
    [[ -n "$name" && -n "$api" ]] || { wcp_error 'Usage: remote api NAME whmapi1|uapi ARGS...'; return 2; }
    local row command args
    row="$(wcp_ssh_get_server "$name")" || true
    [[ -n "$row" ]] || { wcp_error "Unknown server: $name"; return 1; }
    case "$api" in
        whmapi1) command="/usr/local/cpanel/bin/whmapi1" ;;
        uapi) command="/usr/local/cpanel/bin/uapi" ;;
        *) wcp_error 'API must be whmapi1 or uapi.'; return 2 ;;
    esac
    (($#)) && args=" $*" || args=''
    wcp_ssh_exec_row "$row" "$command --output=json$args" "$WCP_SSH_COMMAND_TIMEOUT"
}

wcp_remote_menu() {
    while true; do
        printf '\nRemote SSH\n'
        printf '%s\n' '1. List servers' '2. Add server' '3. Remove server' '4. Test SSH/cPanel' '5. Remote OS profile' '6. Execute command' '7. Interactive shell' '8. Broadcast command' '9. Remote WHM API/UAPI' '0. Back'
        read -r -p 'Select: ' c
        case "$c" in
            1) wcp_ssh_list_servers ;;
            2) wcp_ssh_add_server ;;
            3) read -r -p 'Server name: ' n; wcp_ssh_remove_server "$n" ;;
            4) read -r -p 'Server name: ' n; wcp_ssh_test "$n" ;;
            5) read -r -p 'Server name: ' n; wcp_remote_os_profile "$n" ;;
            6) read -r -p 'Server name: ' n; read -r -p 'Command: ' cmd; wcp_ssh_exec "$n" "$cmd" ;;
            7) read -r -p 'Server name: ' n; wcp_ssh_shell "$n" ;;
            8) read -r -p 'Command: ' cmd; wcp_confirm 'Execute on ALL configured servers?' && wcp_ssh_broadcast "$cmd" ;;
            9) read -r -p 'Server name: ' n; read -r -p 'API (whmapi1/uapi): ' a; read -r -p 'Arguments: ' args; wcp_remote_api_cli "$n" "$a" $args ;;
            0) return ;;
            *) wcp_warn 'Invalid choice.' ;;
        esac
        wcp_pause
    done
}
