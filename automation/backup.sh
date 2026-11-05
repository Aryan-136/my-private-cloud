#!/bin/bash
# ==============================================================================
# Automated Daily Backup Script - My Private Cloud
# Author: Aryan Pandya
# ==============================================================================
set -euo pipefail

BACKUP_SOURCE="/zpool/data"
BACKUP_DEST="/mnt/backup_storage/daily"
LOG_FILE="/var/log/cloud_backup.log"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

echo "[${DATE}] Starting Automated Backup Process..." | tee -a "${LOG_FILE}"

# 1. Create timestamped snapshot
if [ -d "${BACKUP_SOURCE}" ]; then
    rsync -aAXvh --delete "${BACKUP_SOURCE}/" "${BACKUP_DEST}/${DATE}/" >> "${LOG_FILE}" 2>&1
    echo "[$(date)] Rsync to local backup target completed successfully." | tee -a "${LOG_FILE}"
else
    echo "[$(date)] ERROR: Source directory ${BACKUP_SOURCE} not found!" | tee -a "${LOG_FILE}"
    exit 1
fi

# 2. Prune old backups (keep last 7 days)
find "${BACKUP_DEST}" -maxdepth 1 -type d -mtime +7 -exec rm -rf {} +
echo "[$(date)] Pruned snapshots older than 7 days." | tee -a "${LOG_FILE}"

echo "[$(date)] Backup process completed cleanly." | tee -a "${LOG_FILE}"
