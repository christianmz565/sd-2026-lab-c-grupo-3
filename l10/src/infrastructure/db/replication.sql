BEGIN;

ALTER USER postgres WITH REPLICATION;

SELECT pg_create_physical_replication_slot('bogota_slot', false)
WHERE NOT EXISTS (SELECT 1 FROM pg_replication_slots WHERE slot_name = 'bogota_slot');

SELECT pg_create_physical_replication_slot('santiago_slot', false)
WHERE NOT EXISTS (SELECT 1 FROM pg_replication_slots WHERE slot_name = 'santiago_slot');

SELECT pg_create_physical_replication_slot('mexico_slot', false)
WHERE NOT EXISTS (SELECT 1 FROM pg_replication_slots WHERE slot_name = 'mexico_slot');

COMMIT;

SELECT slot_name, slot_type, active FROM pg_replication_slots;
