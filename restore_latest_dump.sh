#!/bin/bash

BASE_DIR="/home/odoo/remote_dumps"
PG_USER="odoo"
export PGPASSWORD="admin"

for db_folder in "$BASE_DIR"/*; do
    DB_NAME=$(basename "$db_folder")
    LATEST_DUMP=$(ls -t "$db_folder"/*.dump 2>/dev/null | head -n 1)
    
    if [[ -n "$LATEST_DUMP" ]]; then
        echo "Restoring $DB_NAME from $LATEST_DUMP"
        psql -U "$PG_USER" -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || \
        createdb -U "$PG_USER" "$DB_NAME"
        pg_restore -U "$PG_USER" -d "$DB_NAME" --clean --if-exists "$LATEST_DUMP"
    fi
done
