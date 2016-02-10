-- Check for isochrone signatures
SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'cdb_isochrone'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry(Geometry, 4326), text, integer[], text[]');
