SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = '_dst_connectusertable'
              AND oidvectortypes(p.proargtypes)  = 'text, text, text, text, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = '_dst_getreturnmetadata'
              AND oidvectortypes(p.proargtypes)  = 'text, text, text, json');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = '_dst_fetchjoinfdwtabledata'
              AND oidvectortypes(p.proargtypes)  = 'text, text, text, text, text, json');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_dataservices_server'
              AND proname = '_dst_disconnectusertable'
              AND oidvectortypes(p.proargtypes)  = 'text, text, text, text, text');

