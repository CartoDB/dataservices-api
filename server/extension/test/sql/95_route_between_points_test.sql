-- Check for routing point to point signatures
SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'cdb_route_point_to_point'
              AND oidvectortypes(p.proargtypes)  = 'text, text, text, geometry, geometry, text, text[], text');

-- Check for routing waypoint route signatures
SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'cdb_route_with_waypoints'
              AND oidvectortypes(p.proargtypes)  = 'text, text, text, geometry[], text, text[], text');
