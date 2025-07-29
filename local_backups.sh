#!/bin/bash

# Config
DATE=$(date +%Y-%m-%d_%H-%M-%S)
DB_NAME="odoo17-server1"
DB_USER="odoo"
DUMP_NAME="${DB_NAME}_${DATE}.dump"

# Paths
LOCAL_DUMP_DIR="/home/odoo/local_backups"
REMOTE_USER="odoo"
REMOTE_HOST="172.31.45.70"
REMOTE_DUMP_DIR="/home/odoo/remote_dumps/${DB_NAME}"

mkdir -p "$LOCAL_DUMP_DIR"
ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${REMOTE_DUMP_DIR}"

export PGPASSWORD="admin"
pg_dump -U "$DB_USER" -h 127.0.0.1 -Fc -v -f "${LOCAL_DUMP_DIR}/${DUMP_NAME}" "$DB_NAME"
[[ $? -ne 0 ]] && echo "❌ Dump failed" && exit 1

rsync -az "${LOCAL_DUMP_DIR}/${DUMP_NAME}" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DUMP_DIR}/"
find "$LOCAL_DUMP_DIR" -name "${DB_NAME}_*.dump" -mtime +7 -delete

echo "✅ .dump backup done for $DB_NAME"
