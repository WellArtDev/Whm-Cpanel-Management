# Remote SSH Engine

v9.2 adds a local-to-remote SSH execution layer. The local host stores only server connection metadata; SSH keys remain managed by OpenSSH.

## Registry

`/root/whmcpanel/config/ssh/servers.conf`

Format:

`name|host|port|user|identity_file|jump_host`

Do not put passwords or private-key material in this file.

## CLI

```bash
./whmcpanel.sh remote list
./whmcpanel.sh remote add
./whmcpanel.sh remote test server01
./whmcpanel.sh remote profile server01
./whmcpanel.sh remote exec server01 'uptime && df -h'
./whmcpanel.sh remote shell server01
./whmcpanel.sh remote broadcast 'uptime'
./whmcpanel.sh remote api server01 whmapi1 listaccts
./whmcpanel.sh remote api server01 uapi --user=cpuser DomainInfo domains_data
```

## Safety

- `BatchMode=yes` prevents password prompts in automation.
- `ConnectTimeout`, keepalive and command timeout limit hung SSH sessions.
- `StrictHostKeyChecking=accept-new` accepts a new host key but rejects changed keys.
- Remote commands are logged locally with server name and exit code. Avoid placing secrets in command arguments because command strings are logged.
- `--dry-run` prints the SSH invocation without connecting.
- Broadcast execution returns failure if any configured server fails.

## Remote OS detection

Detection happens on the target server. The supported cPanel OS profiles remain AlmaLinux, CloudLinux, Rocky Linux and Ubuntu. The remote profile reports package manager, service manager and cPanel API availability.
