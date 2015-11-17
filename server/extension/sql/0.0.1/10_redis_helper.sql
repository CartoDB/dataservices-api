CREATE TYPE cdb_geocoder_server._redis_conf_params AS (
    sentinel_host text,
    sentinel_port int,
    sentinel_master_id text,
    redis_db text,
    timeout float
);

-- Get the Redis configuration from the _conf table --
CREATE OR REPLACE FUNCTION cdb_geocoder_server._get_redis_conf()
RETURNS cdb_geocoder_server._redis_conf_params AS $$
    conf = plpy.execute("SELECT cartodb.CDB_Conf_GetConf('redis_conf') conf")[0]['conf']
    if conf is None:
      plpy.error("There is no redis configuration defined")
    else:
      import json
      params = json.loads(conf)
      return {
        "sentinel_host": params['sentinel_host'],
        "sentinel_port": params['sentinel_port'],
        "sentinel_master_id": params['sentinel_master_id'],
        "timeout": params['timeout'],
        "redis_db": params['redis_db']
      }
$$ LANGUAGE plpythonu;

-- Get the connection to redis from cache or create a new one
CREATE OR REPLACE FUNCTION cdb_geocoder_server._connect_to_redis(user_id name)
RETURNS boolean AS $$
  if user_id in GD and 'redis_connection' in GD[user_id]:
    return False
  else:
    from cartodb_geocoder import redis_helper
    config_params = plpy.execute("""select c.sentinel_host, c.sentinel_port,
        c.sentinel_master_id, c.timeout, c.redis_db
        from cdb_geocoder_server._get_redis_conf() c;""")[0]
    redis_connection = redis_helper.RedisHelper(config_params['sentinel_host'],
        config_params['sentinel_port'],
        config_params['sentinel_master_id'],
        timeout=config_params['timeout'],
        redis_db=config_params['redis_db']).redis_connection()
    GD[user_id] = {'redis_connection': redis_connection}
    return True
$$ LANGUAGE plpythonu;