-- Grant usage on the schema
GRANT USAGE ON SCHEMA public TO readonly_all_databases;

-- Grant SELECT on all current tables and sequences in the schema
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_all_databases;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO readonly_all_databases;

-- Optionally, grant permissions on future tables and sequences in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly_all_databases;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO readonly_all_databases;



-- Grant usage on the public schema
GRANT USAGE ON SCHEMA public TO efcore_user_provider_reporting_users;

-- Grant permissions on all current tables, sequences, and functions in the schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO efcore_user_provider_reporting_users;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO efcore_user_provider_reporting_users;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO efcore_user_provider_reporting_users;

-- Grant permissions on future tables, sequences, and functions in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO efcore_user_provider_reporting_users;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO efcore_user_provider_reporting_users;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON FUNCTIONS TO efcore_user_provider_reporting_users;

-- Grant permissions for running transactions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO efcore_user_provider_reporting_users;