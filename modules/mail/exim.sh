#!/usr/bin/env bash

wcp_mail_queue() {
    wcp_require_bin exim || return
    exim -bp 2>/dev/null || true
}

wcp_mail_queue_summary() {
    wcp_require_bin exim || return
    local total frozen
    total="$(exim -bpc 2>/dev/null || echo 0)"
    frozen="$(exim -bp 2>/dev/null | grep -c 'frozen' || true)"
    printf 'Total queue : %s\nFrozen      : %s\n' "$total" "$frozen"
}

wcp_mail_frozen_cleanup() {
    wcp_require_bin exim || return
    wcp_warn "Frozen-message deletion is destructive."
    local ids
    ids="$(exim -bp 2>/dev/null | awk '/frozen/ {print $3}' | sort -u)"
    [[ -n "$ids" ]] || { wcp_ok "No frozen messages."; return 0; }
    printf '%s\n' "$ids" | head -100
    wcp_confirm "Remove these frozen queue messages?" || return 0
    [[ "$WCP_DRY_RUN" == "1" ]] && return 0
    while IFS= read -r id; do
        [[ "$id" =~ ^[A-Za-z0-9-]+$ ]] || continue
        exim -Mrm "$id" || true
    done <<< "$ids"
}

wcp_mail_tracking_hint() {
    printf 'Use cPanel/WHM Mail Delivery Reports for message-level tracking.\n'
    printf 'Local Exim logs: /var/log/exim_mainlog, /var/log/exim_paniclog, /var/log/exim_rejectlog\n'
}
