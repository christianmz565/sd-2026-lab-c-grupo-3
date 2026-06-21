-- NOTE: change to your own passwords for production environments
\set pgpass `echo "$POSTGRES_PASSWORD"`

-- Active roles (used by postgres, studio, rest)
ALTER USER authenticator WITH PASSWORD :'pgpass';
ALTER USER pgbouncer WITH PASSWORD :'pgpass';
ALTER USER supabase_auth_admin WITH PASSWORD :'pgpass';

-- ---------------------------------------------------------------------------
-- Disabled: roles owned by services not started in the local stack
-- (storage-api, edge-functions). Kept verbatim from upstream so re-enabling
-- the corresponding service in docker-compose.yml works without edits.
-- ---------------------------------------------------------------------------
-- ALTER USER supabase_functions_admin WITH PASSWORD :'pgpass';
-- ALTER USER supabase_storage_admin WITH PASSWORD :'pgpass';
