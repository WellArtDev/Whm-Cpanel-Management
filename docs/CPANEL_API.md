# cPanel API integration

This project uses the official cPanel Developer Portal as the API reference.

## API layers

### WHM API 1
Used for server administration, account administration, and WHM/service operations.

CLI pattern:

```bash
whmapi1 --output=json function parameter=value
```

CloudLinux may require:

```bash
/usr/local/cpanel/bin/whmapi1 --output=json function parameter=value
```

### UAPI
Used for cPanel account-level operations. When called by WHM/root tooling, specify the cPanel user.

```bash
uapi --user=username --output=json Module function
```

## Authentication

For remote HTTPS calls, API tokens are preferred.

WHM:
- 2087 HTTPS
- 2086 HTTP

cPanel/UAPI:
- 2083 HTTPS
- 2082 HTTP

Never commit or log token values.

## Compatibility

API functions can vary by cPanel & WHM version and configuration. The current cPanel API documentation applies to version 138 according to the developer portal. The toolkit therefore detects the local API binary and should verify the function on the target server before depending on it.

## Deprecated API

cPanel API 2 is deprecated. Prefer UAPI when an equivalent UAPI function exists.

## Testing

Before production:
1. Run `./whmcpanel.sh profile`.
2. Run `./whmcpanel.sh health`.
3. Test API connectivity.
4. Verify the exact function and parameter names against the target server.
5. Use a staging account for destructive operations.
