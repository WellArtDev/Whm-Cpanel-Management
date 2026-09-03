# Migration notes from v8.4

The upstream v8.4 script is monolithic. v9 keeps the management concept but moves responsibilities into modules.

Important changes:
1. OS support is intentionally limited to AlmaLinux, CloudLinux, Rocky Linux, and Ubuntu.
2. Package operations no longer assume yum/dnf.
3. Service operations use an adapter and cPanel API where available.
4. Destructive cleanup is no longer bundled into a single "clean all" operation.
5. Active logs are not truncated by default.
6. Account termination requires exact username confirmation.
7. PHP scanner uses heuristic scoring instead of treating every dangerous PHP function as malware.
8. Backups/restores are path-validated and explicitly confirmed.
9. API tokens are never printed by the toolkit.
10. Reports and audit logs are stored under /root/whmcpanel.

The v9 code is a modular replacement foundation. Validate it on a staging cPanel server before production rollout.
