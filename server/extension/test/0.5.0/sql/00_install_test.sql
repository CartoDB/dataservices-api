-- Install dependencies
CREATE EXTENSION postgis;
CREATE EXTENSION schema_triggers;
CREATE EXTENSION plpythonu;
CREATE EXTENSION cartodb;
CREATE EXTENSION cdb_geocoder;

-- Install the extension
CREATE EXTENSION cdb_dataservices_server;

-- Mock the redis server connection to point to this very test db
SELECT cartodb.cdb_conf_setconf('redis_metrics_config', '{"redis_host": "localhost", "redis_port": 26379, "sentinel_master_id": "mymaster", "timeout": 0.1, "redis_db": 5}');
SELECT cartodb.cdb_conf_setconf('redis_metadata_config', '{"redis_host": "localhost", "redis_port": 26379, "sentinel_master_id": "mymaster", "timeout": 0.1, "redis_db": 5}');

-- Mock the varnish invalidation function
-- (used by cdb_geocoder tests)
CREATE OR REPLACE FUNCTION public.cdb_invalidate_varnish(table_name text) RETURNS void AS $$
BEGIN
  RETURN;
END
$$
LANGUAGE plpgsql;

-- Set user quota
SELECT cartodb.CDB_SetUserQuotaInBytes(0);
