#!/bin/bash

export USER=$(whoami)
export PG_SLOT_NAME="replica"

psql -U ${POSTGRES_USER} -f /var/lib/postgresql/src/create_replication_slot.sql

# Clean data dir for backup files
rm -rf /data

# Create base copy of PostgreSQL server
pg_basebackup -U "${POSTGRES_USER}" --pgdata=/data -R --slot="${PG_SLOT_NAME}" --checkpoint=fast

# Remove archive files
rm -rf /data/archive

# Compress data base copy to tar file
tar -cf /data.tar /data
# After creating tar archive we can remove backup files
rm -rf /data

# Check replication slot again
psql -U ${POSTGRES_USER} -c "SELECT slot_name, slot_type, restart_lsn, wal_status FROM pg_replication_slots WHERE slot_name='replica';"
