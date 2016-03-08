-- Install dependencies
CREATE EXTENSION postgis;
CREATE EXTENSION schema_triggers;
CREATE EXTENSION plpythonu;
CREATE EXTENSION cartodb;
CREATE EXTENSION cdb_geocoder;

-- Install the extension
CREATE EXTENSION cdb_dataservices_server;

-- Mock the redis server connection to point to this very test db
SELECT cartodb.cdb_conf_setconf('redis_metrics_config', '{"redis_host": "localhost", "redis_port": 6379, "timeout": 0.1, "redis_db": 5}');
SELECT cartodb.cdb_conf_setconf('redis_metadata_config', '{"redis_host": "localhost", "redis_port": 6379, "timeout": 0.1, "redis_db": 5}');
SELECT cartodb.cdb_conf_setconf('heremaps_conf', '{"app_id": "dummy_id", "app_code": "dummy_code", "geocoder_cost_per_hit": 1}');
SELECT cartodb.cdb_conf_setconf('mapzen_conf', '{"app_key": "dummy_key"}');
SELECT cartodb.cdb_conf_setconf('logger_conf', '{"geocoder_log_path": "/var/log/postgresql/geocodings.log"}');

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
