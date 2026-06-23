BEGIN;

-- Create a view to show replication status (run on primary only)
CREATE OR REPLACE VIEW public.replication_status AS
SELECT
    r.application_name AS nodo,
    r.client_addr AS ip,
    r.state AS estado,
    r.sync_state AS tipo_sync,
    r.sent_lsn,
    r.write_lsn,
    r.flush_lsn,
    r.replay_lsn,
    pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), r.replay_lsn)) AS lag,
    r.write_lag,
    r.flush_lag,
    r.reply_time
FROM pg_stat_replication r
ORDER BY r.application_name;

-- Create a view for replication slots
CREATE OR REPLACE VIEW public.replication_slots AS
SELECT
    slot_name AS nombre,
    slot_type AS tipo,
    active AS activo,
    wal_status AS estado_wal,
    safe_wal_size AS wal_seguro
FROM pg_replication_slots
ORDER BY slot_name;

-- Create a view to check if this is primary or standby
CREATE OR REPLACE VIEW public.node_role AS
SELECT
    CASE
        WHEN pg_is_in_recovery() THEN 'STANDBY (Read-Only)'
        ELSE 'PRIMARY (Read-Write)'
    END AS rol,
    inet_server_addr() AS ip_servidor,
    current_setting('listen_addresses') AS escucha_en,
    current_setting('port') AS puerto;

COMMIT;
