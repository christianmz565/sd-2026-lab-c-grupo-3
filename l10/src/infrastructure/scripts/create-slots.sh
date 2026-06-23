#!/bin/bash
# =============================================================================
# Create replication slots on primary after initialization
# =============================================================================

set -e

echo "=== Creating replication slots ==="

# Wait for PostgreSQL to be ready
until pg_isready -h localhost -p 5432 -U supabase_admin 2>/dev/null; do
    echo "Waiting for PostgreSQL..."
    sleep 2
done

# Grant replication to postgres user
psql -U supabase_admin -c "ALTER USER postgres WITH REPLICATION;" 2>/dev/null || true

# Create replication slots
psql -U supabase_admin -c "SELECT pg_create_physical_replication_slot('bogota_slot', false) WHERE NOT EXISTS (SELECT 1 FROM pg_replication_slots WHERE slot_name = 'bogota_slot');" 2>/dev/null
psql -U supabase_admin -c "SELECT pg_create_physical_replication_slot('santiago_slot', false) WHERE NOT EXISTS (SELECT 1 FROM pg_replication_slots WHERE slot_name = 'santiago_slot');" 2>/dev/null
psql -U supabase_admin -c "SELECT pg_create_physical_replication_slot('mexico_slot', false) WHERE NOT EXISTS (SELECT 1 FROM pg_replication_slots WHERE slot_name = 'mexico_slot');" 2>/dev/null

# Verify slots were created
echo "=== Verifying replication slots ==="
psql -U supabase_admin -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"

echo "=== Replication slots created successfully ==="
