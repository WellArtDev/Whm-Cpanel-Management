# Legacy source

The upstream repository currently has a monolithic `whmcpanel.sh` v8.4.

The v9 package does not silently embed a stale copy of that monolith. Use the upstream repository's v8.4 script as the migration reference and move remaining legacy functions into the appropriate v9 module as they are verified.

This avoids shipping an unreviewed duplicate of the old destructive behavior.
