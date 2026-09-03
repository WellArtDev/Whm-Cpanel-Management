# WhmCpanel Management v9.0 Modular

A modular Bash toolkit for managing cPanel & WHM servers.

## Supported operating systems

The OS compatibility gate intentionally supports only:

- AlmaLinux
- CloudLinux
- Rocky Linux
- Ubuntu

Other Linux distributions are rejected by the preflight layer.

## cPanel API integration

The API layer follows the official cPanel Developer Portal conventions:

- WHM API 1 through `whmapi1`
- UAPI through `uapi`
- Prefer UAPI over deprecated cPanel API 2 when an equivalent exists
- WHM API 1 secure HTTPS uses port 2087
- cPanel/UAPI secure HTTPS uses port 2083
- API tokens are preferred over the deprecated Remote Access Key/access hash
- Account-level UAPI calls must be executed in the correct cPanel-user context

Use `profile`, `api catalog`, and the API audit module to inspect available capabilities on the target server.

## Requirements

- Bash 4+
- root
- cPanel & WHM for WHM/UAPI/account features
- Common tools are detected before use
- Some features require cPanel-native binaries such as `whmapi1`, `uapi`, `pkgacct`, or `restorepkg`

## Quick start

```bash
chmod +x whmcpanel.sh
sudo ./whmcpanel.sh
```

Read-only commands:

```bash
./whmcpanel.sh profile
./whmcpanel.sh health
./whmcpanel.sh audit
./whmcpanel.sh disk
./whmcpanel.sh report
```

Dry-run:

```bash
./whmcpanel.sh --dry-run menu
```

## Directory layout

```text
whmcpanel.sh
config/
lib/
modules/
menus/
tests/
docs/
legacy/
```

Every module is sourced independently. Add a new feature under `modules/<domain>/` rather than expanding the launcher.

## Safety model

```text
detect
  -> validate
  -> preview
  -> confirm
  -> execute
  -> verify
  -> audit
```

Destructive operations are not automatically executed.

## State

```text
/root/whmcpanel/
├── logs/
├── reports/
├── backups/
├── cache/
└── config/
```

## Testing

Run:

```bash
bash tests/run_tests.sh
```

Also recommended on a development machine:

```bash
bash -n whmcpanel.sh
find . -name '*.sh' -print0 | xargs -0 -n1 bash -n
shellcheck whmcpanel.sh lib/*.sh modules/**/*.sh menus/*.sh tests/*.sh
```

## Production warning

This package is a refactor foundation and must be tested on a staging cPanel/WHM server before production use. cPanel API function availability can vary by installed version and configuration, so every API-backed operation should be verified on the target server.

## v9.2 Remote SSH

v9.2 adds local-to-remote SSH management, multi-server registry, remote OS/cPanel detection, command execution, interactive SSH, broadcast execution, and remote WHM API/UAPI execution. See `docs/REMOTE_SSH.md`.
