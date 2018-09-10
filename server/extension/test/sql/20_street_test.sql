-- Check for namedplaces signatures
SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'cdb_geocode_street_point'
              AND oidvectortypes(p.proargtypes)  = 'text, text, text, text, text, text');
