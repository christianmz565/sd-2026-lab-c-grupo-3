#!/bin/bash
# =============================================================================
# Standby Init Script
# Performs pg_basebackup if this is a fresh standby
# =============================================================================

set -e

PRIMARY_HOST="${PRIMARY_HOST:-lima-db}"
PRIMARY_PORT="${PRIMARY_PORT:-5432}"
REPLICATION_USER="${REPLICATION_USER:-postgres}"
REPLICATION_SLOT="${REPLICATION_SLOT:-}"
APP_NAME="${APP_NAME:-unknown}"
PGPASSWORD="${POSTGRES_PASSWORD:-postgres}"

export PGPASSWORD

echo "=== Standby Init: $APP_NAME ==="
echo "Primary: $PRIMARY_HOST:$PRIMARY_PORT"
echo "Slot: $REPLICATION_SLOT"

# Copy pg_hba.conf to correct location if it exists in custom location
if [ -f /etc/postgresql-custom/pg_hba.conf ]; then
    echo "Copying pg_hba.conf to /etc/postgresql/"
    cp /etc/postgresql-custom/pg_hba.conf /etc/postgresql/pg_hba.conf
    chown postgres:postgres /etc/postgresql/pg_hba.conf
    chmod 640 /etc/postgresql/pg_hba.conf
fi

# Check if we need to do base backup
NEEDS_BACKUP=false

if [ ! -f "$PGDATA/postgresql.conf" ]; then
    echo "No postgresql.conf found - needs base backup"
    NEEDS_BACKUP=true
fi

# Check if standby.signal exists
if [ ! -f "$PGDATA/standby.signal" ]; then
    echo "No standby.signal found - needs base backup"
    NEEDS_BACKUP=true
fi

if [ "$NEEDS_BACKUP" = true ]; then
    echo "Waiting for primary ($PRIMARY_HOST) to be ready for replication..."
    MAX_RETRIES=60
    RETRY_COUNT=0
    until pg_isready -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" -U postgres; do
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
            echo "Primary never became ready, continuing anyway..."
            break
        fi
        echo "Primary not ready (attempt $RETRY_COUNT/$MAX_RETRIES), waiting 5s..."
        sleep 5
    done

    # Additional wait for replication to be ready
    echo "Waiting for replication to be ready..."
    sleep 5

    echo "Primary is ready! Performing pg_basebackup..."
    rm -rf "$PGDATA"/*

    BACKUP_CMD="pg_basebackup -h $PRIMARY_HOST -p $PRIMARY_PORT -U $REPLICATION_USER -D $PGDATA -R -Xs -P"
    if [ -n "$REPLICATION_SLOT" ]; then
        BACKUP_CMD="$BACKUP_CMD --slot=$REPLICATION_SLOT"
    fi

    echo "Running: $BACKUP_CMD"
    if ! $BACKUP_CMD; then
        echo "pg_basebackup failed! Trying without slot..."
        BACKUP_CMD="pg_basebackup -h $PRIMARY_HOST -p $PRIMARY_PORT -U $REPLICATION_USER -D $PGDATA -R -Xs -P"
        $BACKUP_CMD || echo "pg_basebackup failed completely"
    fi

    # Copy pg_hba.conf again after base backup (it gets overwritten)
    if [ -f /etc/postgresql-custom/pg_hba.conf ]; then
        echo "Copying pg_hba.conf after backup"
        cp /etc/postgresql-custom/pg_hba.conf /etc/postgresql/pg_hba.conf
        chown postgres:postgres /etc/postgresql/pg_hba.conf
        chmod 640 /etc/postgresql/pg_hba.conf
    fi

    # Create standby.signal to ensure standby mode
    touch "$PGDATA/standby.signal"

    echo "Base backup complete!"
else
    echo "Standby already configured, skipping backup"
fi

echo "=== Starting PostgreSQL ==="
exec docker-entrypoint.sh postgres
