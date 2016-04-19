SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_get_demographic_snapshot'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_get_segment_snapshot'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, text');