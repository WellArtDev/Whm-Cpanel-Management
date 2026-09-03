#!/usr/bin/env bash

wcp_security_audit() {
    printf '=== SECURITY AUDIT ===\n'
    local score=100
    local ssh
    if [[ -r /etc/ssh/sshd_config ]]; then
        if grep -Eq '^[[:space:]]*PermitRootLogin[[:space:]]+yes([[:space:]]|$)' /etc/ssh/sshd_config; then
            printf '[HIGH] SSH PermitRootLogin yes\n'; ((score-=20))
        fi
        if grep -Eq '^[[:space:]]*PasswordAuthentication[[:space:]]+yes([[:space:]]|$)' /etc/ssh/sshd_config; then
            printf '[INFO] SSH password authentication enabled\n'; ((score-=5))
        fi
    fi
    if wcp_has csf; then printf '[PASS] CSF detected\n'; else printf '[WARN] CSF not detected\n'; ((score-=5)); fi
    local root_used
    root_used="$(df -P / | awk 'NR==2 {gsub(/%/,"",$5);print $5+0}')"
    if ((root_used >= WCP_DISK_CRIT)); then printf '[CRIT] Disk usage %s%%\n' "$root_used"; ((score-=20)); fi
    ((score<0)) && score=0
    printf '\nSecurity score: %s/100\n' "$score"
}

wcp_security_world_writable() {
    printf 'World-writable files outside known runtime paths:\n'
    find / -xdev -type f -perm -0002 \
        -not -path '/proc/*' -not -path '/sys/*' -not -path '/dev/*' \
        -not -path '/tmp/*' -not -path '/var/tmp/*' 2>/dev/null | head -200
}

wcp_security_suid() {
    find / -xdev -type f -perm /6000 \
        -not -path '/proc/*' -not -path '/sys/*' -not -path '/dev/*' 2>/dev/null | head -300
}

wcp_security_cron_audit() {
    printf 'Potentially suspicious cron entries:\n'
    grep -RInE '(curl|wget).*(\||;|&&).*bash|base64[[:space:]]+-d|/tmp/|/var/tmp/' \
        /etc/cron* /var/spool/cron /var/spool/cron/crontabs 2>/dev/null | head -200 || true
}
