-- Get the connection to redis from cache or create a new one
CREATE OR REPLACE FUNCTION cdb_dataservices_server._connect_to_redis(user_id text)
RETURNS boolean AS $$
  cache_key = "redis_connection_{0}".format(user_id)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.tools import RedisConnection, RedisDBConfig
    metadata_config = RedisDBConfig('redis_metadata_config', plpy)
    metrics_config = RedisDBConfig('redis_metrics_config', plpy)
    redis_metadata_connection = RedisConnection(metadata_config).redis_connection()
    redis_metrics_connection = RedisConnection(metrics_config).redis_connection()
    GD[cache_key] = {
      'redis_metadata_connection': redis_metadata_connection,
      'redis_metrics_connection': redis_metrics_connection,
    }
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER STABLE PARALLEL RESTRICTED;
