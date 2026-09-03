# v9.0 feature matrix

## Foundation
- Modular Bash architecture
- Supported OS gate: AlmaLinux, CloudLinux, Rocky Linux, Ubuntu
- OS package adapter: dnf/yum or apt
- Service adapter: systemd/SysV
- cPanel/WHM detection
- WHM API 1 and UAPI wrappers
- Dry-run mode
- Explicit confirmations
- Double-confirmation for account termination
- Root-only execution
- Audit logs and reports
- Plugin directory

## Operations
- Server health check and health score
- Service status/restart
- Account list/info/suspend/unsuspend/terminate/disk usage
- Account backup/restore
- Exim queue/summary/frozen cleanup
- DNS zone listing/dump/export
- SSL expiry and AutoSSL
- MySQL/MariaDB status/processlist/size
- Disk and inode analyzer
- Maintenance analysis and safer cleanup
- Cron audit/export
- Web and mail troubleshooting
- Full report generation

## Security
- SSH configuration checks
- CSF detection
- cPHulk detection
- World-writable file audit
- SUID/SGID audit
- Cron suspicious-pattern audit
- PHP heuristic scoring
- PHP quarantine workflow
- API-token audit guidance

## Design rule
WHM/cPanel native API is preferred over direct filesystem manipulation. OS package/service adapters are used only where appropriate.
