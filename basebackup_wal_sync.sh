#!/bin/bash

STORE_NAME="server-1"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
REMOTE_USER="odoo"
REMOTE_HOST="172.31.45.70"
REMOTE_DIR="/home/odoo/base_backups/${STORE_NAME}/${DATE}"
TMP_BACKUP="/tmp/base_${STORE_NAME}_${DATE}.tar.gz"

export PGPASSWORD="admin"
pg_basebackup -h 127.0.0.1 -U postgres -Ft -z -X fetch -D "$TMP_BACKUP" -P -v -R
[[ $? -ne 0 ]] && echo "❌ Base backup failed" && exit 1

ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${REMOTE_DIR}/WALs"
rsync -az "$TMP_BACKUP" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"
rsync -az /home/odoo/wal_archive/ "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/WALs/"
rm -f "$TMP_BACKUP"

echo "✅ Base backup + WALs sent to central from $STORE_NAME"
