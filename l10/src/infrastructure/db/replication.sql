-- Replication setup for FedEx Peru
-- Note: Replication slots are created by init-replication.sh after Lima is healthy
-- because SET SESSION AUTHORIZATION doesn't work in Docker entrypoint psql scripts

-- Grant replication to postgres user
ALTER USER postgres WITH REPLICATION;

-- Verify WAL level is replica
SELECT current_setting('wal_level') AS wal_level;
