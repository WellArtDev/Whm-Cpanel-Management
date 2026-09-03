#!/usr/bin/env bash

wcp_db_status() {
    if [[ -n "$WCP_WHMAPI" ]]; then
        wcp_whmapi servicestatus "service=mysql" 2>/dev/null || true
    fi
    if wcp_has mysqladmin; then
        mysqladmin ping 2>/dev/null || true
    fi
}

wcp_db_processlist() {
    if wcp_has mysql; then
        mysql --batch --skip-column-names -e 'SHOW FULL PROCESSLIST;' 2>/dev/null || true
    elif wcp_has mariadb; then
        mariadb --batch --skip-column-names -e 'SHOW FULL PROCESSLIST;' 2>/dev/null || true
    else
        wcp_error "mysql/mariadb client not found."
    fi
}

wcp_db_size() {
    if wcp_has mysql; then
        mysql -e "SELECT table_schema AS db_name, ROUND(SUM(data_length+index_length)/1024/1024,2) AS size_mb FROM information_schema.tables GROUP BY table_schema ORDER BY size_mb DESC;" 2>/dev/null || true
    fi
}
