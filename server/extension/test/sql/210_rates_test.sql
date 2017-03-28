SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'cdb_service_get_rate_limit'
              AND oidvectortypes(p.proargtypes)  = 'text, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'cdb_service_set_user_rate_limit'
              AND oidvectortypes(p.proargtypes)  = 'text, text, text, json');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'cdb_service_set_org_rate_limit'
              AND oidvectortypes(p.proargtypes)  = 'text, text, text, json');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'cdb_service_set_server_rate_limit'
              AND oidvectortypes(p.proargtypes)  = 'text, text, text, json');
