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

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_getdemographicsnapshot'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_getsegmentsnapshot'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_getmeasure'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, text, text, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_getcategory'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, text, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_getuscensusmeasure'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, text, text, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_getuscensuscategory'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, text, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_getpopulation'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, text, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_search'
              AND oidvectortypes(p.proargtypes)  = 'text, text, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_getavailableboundaries'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_getboundary'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_getboundaryid'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_getboundarybyid'
              AND oidvectortypes(p.proargtypes)  = 'text, text, text, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_getboundariesbygeometry'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, text, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_getboundariesbypointandradius'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, numeric, text, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_getpointsbygeometry'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, text, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = 'obs_getpointsbypointandradius'
              AND oidvectortypes(p.proargtypes)  = 'text, text, geometry, numeric, text, text, text');