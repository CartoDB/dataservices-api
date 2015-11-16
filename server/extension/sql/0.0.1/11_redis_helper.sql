-- Get the connection to redis from cache or create a new one
CREATE OR REPLACE FUNCTION cdb_geocoder_server._connect_to_redis(user_id name)
RETURNS boolean AS $$
  if user_id in GD and 'redis_connection' in GD[user_id]:
    return False
  else:
    from cartodb_geocoder import redis_helper
    config_params = plpy.execute("select c.host, c.port, c.timeout, c.db from cdb_geocoder_server._get_redis_conf() c;")[0]
    redis_connection = redis_helper.RedisHelper(config_params['host'], config_params['port'], config_params['db']).redis_connection()
    GD[user_id] = {'redis_connection': redis_connection}
    return True
$$ LANGUAGE plpythonu;

CREATE TYPE cdb_geocoder_server._redis_conf_params AS (
    host text,
    port int,
    timeout float,
    db text
);

CREATE OR REPLACE FUNCTION cdb_geocoder_server._get_redis_conf()
RETURNS cdb_geocoder_server._redis_conf_params AS $$
    conf = plpy.execute("SELECT cdb_geocoder_server._config_get('redis_conf') conf")[0]['conf']
    if conf is None:
      plpy.error("There is no redis configuration defined")
    else:
      import json
      params = json.loads(conf)
      return { "host": params['host'], "port": params['port'], 'timeout': params['timeout'], 'db': params['db'] }
$$ LANGUAGE plpythonu;