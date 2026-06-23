-- NOTE: change to your own passwords for production environments

-- Active roles (used by postgres, studio, rest)
-- Using fixed password for dev environment
ALTER USER authenticator WITH PASSWORD 'postgres';
ALTER USER pgbouncer WITH PASSWORD 'postgres';
ALTER USER supabase_auth_admin WITH PASSWORD 'postgres';
