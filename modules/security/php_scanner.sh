#!/usr/bin/env bash

wcp_php_score_file() {
    local file="$1" score=0
    [[ -f "$file" ]] || return 1
    grep -Eq '(^|[^A-Za-z_])(eval|assert)[[:space:]]*\(' "$file" 2>/dev/null && ((score+=20))
    grep -Eq 'base64_decode[[:space:]]*\(' "$file" 2>/dev/null && ((score+=5))
    grep -Eq 'gzinflate|gzuncompress|str_rot13' "$file" 2>/dev/null && ((score+=10))
    grep -Eq 'shell_exec|passthru|proc_open|popen' "$file" 2>/dev/null && ((score+=15))
    grep -Eq 'preg_replace[[:space:]]*\([^;]*[\"'\"']/e[\"'\"']' "$file" 2>/dev/null && ((score+=25))
    grep -Eiq 'c99|r57|wso|webshell|FilesMan' "$file" 2>/dev/null && ((score+=40))
    printf '%s\t%s\n' "$score" "$file"
}

wcp_php_scan_home() {
    local root="${1:-/home}"
    [[ -d "$root" ]] || { wcp_error "Directory not found: $root"; return 1; }
    printf 'score\tfile\n'
    while IFS= read -r -d '' file; do
        wcp_php_score_file "$file"
    done < <(find "$root" -xdev -type f \( -name '*.php' -o -name '*.phtml' -o -name '*.php[0-9]' \) -print0 2>/dev/null) |
        awk -F '\t' '$1>=40 {print}' | sort -nr
    printf '\nNOTE: score is heuristic, not a malware verdict.\n'
}

wcp_php_quarantine() {
    local file="$1"
    [[ -f "$file" ]] || return 1
    case "$file" in /home/*) ;; *) wcp_error "Only /home files may be quarantined."; return 2;; esac
    local q="$WCP_STATE_DIR/quarantine/$(date +%Y%m%d)"
    mkdir -p "$q"; chmod 700 "$WCP_STATE_DIR/quarantine" "$q"
    wcp_confirm_exact "$(basename "$file")" || return 1
    [[ "$WCP_DRY_RUN" == "1" ]] && return 0
    mv -- "$file" "$q/"
    wcp_ok "Quarantined to $q/"
}
