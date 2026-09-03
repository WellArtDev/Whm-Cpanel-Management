#!/usr/bin/env bash

wcp_plugins_list() {
    printf '=== PLUGINS ===\n'
    if [[ -d "$WCP_PLUGIN_DIR" ]]; then
        find "$WCP_PLUGIN_DIR" -maxdepth 1 -type f -name '*.sh' -printf '%f\n' | sort
    else
        printf 'No plugin directory: %s\n' "$WCP_PLUGIN_DIR"
    fi
}

wcp_plugins_run() {
    local plugin="$1"
    [[ "$plugin" =~ ^[A-Za-z0-9._-]+\.sh$ ]] || { wcp_error "Invalid plugin name."; return 2; }
    local path="$WCP_PLUGIN_DIR/$plugin"
    [[ -f "$path" && -x "$path" ]] || { wcp_error "Plugin not found/executable."; return 1; }
    wcp_log INFO "plugin=$plugin"
    "$path"
}
