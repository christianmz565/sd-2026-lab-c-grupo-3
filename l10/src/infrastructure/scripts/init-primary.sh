#!/bin/bash
# =============================================================================
# Primary Init Script
# Copies pg_hba.conf and starts PostgreSQL
# =============================================================================

set -e

echo "=== Primary Init ==="

# Copy pg_hba.conf to correct location if it exists in custom location
if [ -f /etc/postgresql-custom/pg_hba.conf ]; then
    echo "Copying pg_hba.conf to /etc/postgresql/"
    cp /etc/postgresql-custom/pg_hba.conf /etc/postgresql/pg_hba.conf
    chown postgres:postgres /etc/postgresql/pg_hba.conf
    chmod 640 /etc/postgresql/pg_hba.conf
fi

echo "=== Starting PostgreSQL ==="
exec docker-entrypoint.sh postgres
