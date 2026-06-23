#!/bin/bash
# =============================================================================
# Primary Init Script
# Copies custom pg_hba.conf to PGDATA, then runs docker-entrypoint.sh
# =============================================================================

set -e

echo "=== Primary Init: Setting up pg_hba.conf ==="

# The mounted pg_hba.conf is at /etc/postgresql-custom/pg_hba.conf
# We need to copy it to PGDATA so PostgreSQL uses it
if [ -f /etc/postgresql-custom/pg_hba.conf ]; then
    echo "Custom pg_hba.conf found at /etc/postgresql-custom/"
else
    echo "WARNING: Custom pg_hba.conf not found at /etc/postgresql-custom/"
fi

# Start docker-entrypoint.sh which will:
# 1. Run initdb if needed (first time)
# 2. Run init scripts (including replication.sql)
# 3. Start PostgreSQL
echo "=== Starting docker-entrypoint.sh ==="
exec docker-entrypoint.sh postgres
