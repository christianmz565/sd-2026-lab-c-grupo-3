#!/bin/bash
# =============================================================================
# Standby Init Script
# Performs pg_basebackup, then starts PostgreSQL
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
echo "Primary: $PRIMARY_HOST:$PRIMARY_PORT, Slot: $REPLICATION_SLOT"

# Check if we need base backup
SKIP_BACKUP=false
if [ -f "$PGDATA/standby.signal" ] && [ -f "$PGDATA/postgresql.conf" ]; then
    echo "Already configured as standby, skipping backup"
    SKIP_BACKUP=true
fi

if [ "$SKIP_BACKUP" = false ]; then
    echo "Waiting for primary to be ready..."
    MAX_RETRIES=90
    RETRY_COUNT=0
    until pg_isready -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" -U postgres 2>/dev/null; do
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
            echo "Max retries reached, giving up"
            exit 1
        fi
        echo "Primary not ready (attempt $RETRY_COUNT/$MAX_RETRIES), waiting..."
        sleep 2
    done
    echo "Primary is ready!"

    # Give extra time for replication to be fully ready
    sleep 5

    echo "Performing pg_basebackup..."
    rm -rf "$PGDATA"/*

    BACKUP_CMD="pg_basebackup -h $PRIMARY_HOST -p $PRIMARY_PORT -U $REPLICATION_USER -D $PGDATA -R -Xs -P"
    if [ -n "$REPLICATION_SLOT" ]; then
        BACKUP_CMD="$BACKUP_CMD --slot=$REPLICATION_SLOT"
    fi

    echo "Running: $BACKUP_CMD"
    if ! $BACKUP_CMD; then
        echo "pg_basebackup failed, trying without slot..."
        rm -rf "$PGDATA"/*
        pg_basebackup -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" -U "$REPLICATION_USER" -D "$PGDATA" -R -Xs -P || {
            echo "pg_basebackup failed completely!"
            exit 1
        }
    fi

    # Configure standby settings after base backup
    echo "Configuring standby settings..."

    # Update primary_conninfo in postgresql.auto.conf to include password
    if [ -f "$PGDATA/postgresql.auto.conf" ]; then
        # Update application_name if it has a variable
        sed -i "s/\${APP_NAME}/$APP_NAME/g" "$PGDATA/postgresql.auto.conf" 2>/dev/null || true

        # Add password to primary_conninfo if not present
        if grep -q "primary_conninfo" "$PGDATA/postgresql.auto.conf"; then
            # Replace or add password to primary_conninfo
            sed -i "s/primary_conninfo = '.*'/primary_conninfo = 'host=$PRIMARY_HOST port=$PRIMARY_PORT user=$REPLICATION_USER password=$PGPASSWORD application_name=$APP_NAME'/" "$PGDATA/postgresql.auto.conf" 2>/dev/null || true
        fi

        # Add slot name if specified
        if [ -n "$REPLICATION_SLOT" ]; then
            if ! grep -q "primary_slot_name" "$PGDATA/postgresql.auto.conf" 2>/dev/null; then
                echo "primary_slot_name = '$REPLICATION_SLOT'" >> "$PGDATA/postgresql.auto.conf"
            fi
        fi
    fi

    # Add hot_standby if not present
    if ! grep -q "hot_standby" "$PGDATA/postgresql.auto.conf" 2>/dev/null; then
        echo "hot_standby = on" >> "$PGDATA/postgresql.auto.conf"
    fi

    # Add recovery target if not present
    if ! grep -q "recovery_target_timeline" "$PGDATA/postgresql.auto.conf" 2>/dev/null; then
        echo "recovery_target_timeline = 'latest'" >> "$PGDATA/postgresql.auto.conf"
    fi

    # Set listen_addresses to accept connections from Docker network
    if ! grep -q "listen_addresses" "$PGDATA/postgresql.auto.conf" 2>/dev/null; then
        echo "listen_addresses = '*'" >> "$PGDATA/postgresql.auto.conf"
    else
        sed -i "s/listen_addresses = .*/listen_addresses = '*'/" "$PGDATA/postgresql.auto.conf" 2>/dev/null || true
    fi

    # Copy pg_hba.conf to data directory (it gets overwritten by base backup)
    if [ -f /etc/postgresql-custom/pg_hba.conf ]; then
        cp /etc/postgresql-custom/pg_hba.conf "$PGDATA/pg_hba.conf"
        chown postgres:postgres "$PGDATA/pg_hba.conf"
        chmod 640 "$PGDATA/pg_hba.conf"
    fi

    echo "Base backup complete!"
else
    echo "Skipping backup, starting PostgreSQL..."
fi

echo "=== Starting PostgreSQL ==="
exec docker-entrypoint.sh postgres
