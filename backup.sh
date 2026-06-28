#!/bin/sh
# Automated Database Backup Script for Fabbit.org SQLite database
# Schedule this script to run daily using crontab:
# 0 2 * * * /bin/sh /var/www/fabbit/backup.sh

# Configurations
BACKUP_DIR="/var/www/fabbit/backups/db"
SOURCE_DB="/var/www/fabbit/prisma/dev.db"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/fabbit_backup_${TIMESTAMP}.db"
RETENTION_DAYS=30

# Create backup directory if it does not exist
mkdir -p "${BACKUP_DIR}"

# Run backup
echo "Starting database backup at $(date)..."

if [ -f "${SOURCE_DB}" ]; then
  # Safe copy SQLite database
  cp "${SOURCE_DB}" "${BACKUP_FILE}"
  
  if [ $? -eq 0 ]; then
    echo "Backup completed successfully: ${BACKUP_FILE}"
    
    # Prune old backups exceeding retention cycle
    echo "Cleaning up backups older than ${RETENTION_DAYS} days..."
    find "${BACKUP_DIR}" -name "fabbit_backup_*.db" -type f -mtime +${RETENTION_DAYS} -exec rm -f {} \;
    echo "Pruning completed."
  else
    echo "ERROR: Backup file copy copy operation failed." >&2
    exit 1
  fi
else
  echo "ERROR: Source SQLite database file not found at ${SOURCE_DB}" >&2
  exit 1
fi

echo "Database backup process completed successfully."
exit 0
