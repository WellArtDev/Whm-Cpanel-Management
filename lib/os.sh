#!/usr/bin/env bash

WCP_OS_ID=""
WCP_OS_NAME=""
WCP_OS_VERSION=""
WCP_PKG_MGR=""
WCP_SERVICE_MGR=""
WCP_OS_SUPPORTED=0

wcp_detect_os() {
    local id="" version="" name=""
    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        id="${ID,,}"
        version="${VERSION_ID:-}"
        name="${PRETTY_NAME:-${NAME:-$id}}"
    fi
    WCP_OS_ID="$id"
    WCP_OS_NAME="$name"
    WCP_OS_VERSION="$version"

    case "$id" in
        almalinux)
            WCP_PKG_MGR="dnf"; WCP_OS_SUPPORTED=1 ;;
        cloudlinux|cloudlinux-server)
            WCP_PKG_MGR="$(wcp_has dnf && echo dnf || echo yum)"; WCP_OS_SUPPORTED=1 ;;
        rocky)
            WCP_PKG_MGR="dnf"; WCP_OS_SUPPORTED=1 ;;
        ubuntu)
            WCP_PKG_MGR="apt-get"; WCP_OS_SUPPORTED=1 ;;
        *)
            WCP_PKG_MGR=""
            WCP_OS_SUPPORTED=0
            ;;
    esac

    if wcp_has systemctl; then
        WCP_SERVICE_MGR="systemd"
    elif wcp_has service; then
        WCP_SERVICE_MGR="sysv"
    else
        WCP_SERVICE_MGR="unknown"
    fi
}

wcp_os_supported() { [[ "$WCP_OS_SUPPORTED" == "1" ]]; }

wcp_os_assert_supported() {
    wcp_os_supported || {
        wcp_error "Unsupported OS: ${WCP_OS_NAME:-unknown}."
        wcp_error "Supported: AlmaLinux, CloudLinux, Rocky Linux, Ubuntu."
        return 1
    }
}

wcp_pkg_install() {
    local pkg="$1"
    wcp_os_assert_supported || return
    case "$WCP_PKG_MGR" in
        dnf|yum) wcp_run "$WCP_PKG_MGR" install -y -- "$pkg" ;;
        apt-get) wcp_run apt-get update && wcp_run apt-get install -y -- "$pkg" ;;
    esac
}

wcp_pkg_update() {
    wcp_os_assert_supported || return
    case "$WCP_PKG_MGR" in
        dnf|yum) wcp_run "$WCP_PKG_MGR" makecache -y ;;
        apt-get) wcp_run apt-get update ;;
    esac
}

wcp_pkg_upgrade() {
    wcp_os_assert_supported || return
    case "$WCP_PKG_MGR" in
        dnf|yum) wcp_run "$WCP_PKG_MGR" upgrade -y ;;
        apt-get) wcp_run apt-get upgrade -y ;;
    esac
}

wcp_pkg_clean() {
    wcp_os_assert_supported || return
    case "$WCP_PKG_MGR" in
        dnf|yum) wcp_run "$WCP_PKG_MGR" clean all ;;
        apt-get) wcp_run apt-get clean ;;
    esac
}

wcp_service() {
    local action="$1" service="$2"
    case "$WCP_SERVICE_MGR" in
        systemd) wcp_run systemctl "$action" "$service" ;;
        sysv) wcp_run service "$service" "$action" ;;
        *) wcp_error "No supported service manager."; return 1 ;;
    esac
}

wcp_service_status() {
    local service="$1"
    case "$WCP_SERVICE_MGR" in
        systemd) systemctl is-active --quiet "$service" ;;
        sysv) service "$service" status >/dev/null 2>&1 ;;
        *) return 1 ;;
    esac
}

wcp_service_restart() { wcp_service restart "$1"; }

wcp_os_profile() {
    wcp_detect_os
    printf '%-18s %s\n' "OS" "${WCP_OS_NAME:-unknown}"
    printf '%-18s %s\n' "OS ID" "${WCP_OS_ID:-unknown}"
    printf '%-18s %s\n' "Version" "${WCP_OS_VERSION:-unknown}"
    printf '%-18s %s\n' "Package manager" "${WCP_PKG_MGR:-unsupported}"
    printf '%-18s %s\n' "Service manager" "$WCP_SERVICE_MGR"
    if wcp_os_supported; then
        wcp_ok "OS compatibility: PASS"
    else
        wcp_error "OS compatibility: FAIL"
    fi
}
