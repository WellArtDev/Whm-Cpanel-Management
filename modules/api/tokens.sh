#!/usr/bin/env bash

wcp_api_token_audit() {
    wcp_cpanel_assert || return
    if [[ -d /root/.accesshash ]]; then
        printf '[INFO] Legacy accesshash exists at /root/.accesshash\n'
    fi
    printf '[INFO] Review WHM API tokens from WHM > Development > Manage API Tokens.\n'
    printf '[INFO] Do not print token values into terminal logs.\n'
}
