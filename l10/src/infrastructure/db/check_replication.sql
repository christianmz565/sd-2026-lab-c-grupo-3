-- =============================================================================
-- REPLICATION MONITORING SCRIPT
-- Run this on PRIMARY (Lima) to check replication status
-- =============================================================================

-- Check replication slots
SELECT
  slot_name,
  slot_type,
  datname AS database,
  active,
  restart_lsn,
  (pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) / 1024 / 1024)::numeric(10,2) AS lag_mb
FROM pg_replication_slots
WHERE slot_type = 'physical';

-- Check streaming replication status
SELECT
  client_addr AS client_address,
  usename AS username,
  application_name,
  state,
  sync_state,
  (pg_wal_lsn_diff(pg_current_wal_lsn(), reply_lsn) / 1024 / 1024)::numeric(10,2) AS lag_mb,
  status
FROM pg_stat_replication;

-- Check wal sender status
SELECT
  pid,
  usesysid,
  usename,
  application_name,
  client_addr,
  state,
  sent_lsn,
  write_lsn,
  flush_lsn,
  replay_lsn
FROM pg_stat_replication;

-- Force slot creation (if needed)
-- SELECT pg_create_physical_replication_slot('bogota_slot', false);
