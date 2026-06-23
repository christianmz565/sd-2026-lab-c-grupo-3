#!/bin/bash
# =============================================================================
# FAILOVER SCRIPT
# Promotes a standby to primary when the primary fails
# =============================================================================

set -e

STANDBY_HOST="${1:-bogota-db}"
STANDBY_PORT="${2:-5432}"

echo "=== FedEx Peru Replication Failover ==="
echo "Promoting standby: $STANDBY_HOST:$STANDBY_PORT"
echo ""

# Check current state
echo "1. Checking current replication state..."
psql -h "$STANDBY_HOST" -p "$STANDBY_PORT" -U postgres -c "SELECT pg_is_in_recovery();"

# Check who is primary
echo ""
echo "2. Current replication status on $STANDBY_HOST..."
psql -h "$STANDBY_HOST" -p "$STANDBY_PORT" -U postgres -c "SELECT * FROM pg_stat_replication;"

# Promote standby to primary
echo ""
echo "3. Promoting $STANDBY_HOST to primary..."
psql -h "$STANDBY_HOST" -p "$STANDBY_PORT" -U postgres -c "SELECT pg_promote();"

# Verify promotion
echo ""
echo "4. Verifying promotion..."
sleep 2
psql -h "$STANDBY_HOST" -p "$STANDBY_PORT" -U postgres -c "SELECT pg_is_in_recovery() AS is_standby;"

echo ""
echo "=== Failover Complete ==="
echo "$STANDBY_HOST is now the PRIMARY"
echo ""
echo "Next steps:"
echo "1. Update other standbys to point to new primary: $STANDBY_HOST"
echo "2. Update application connection strings"
echo "3. Investigate failure of old primary"
