ALTER TYPE cdb_dataservices_server._redis_conf_params ADD ATTRIBUTE redis_host text;
ALTER TYPE cdb_dataservices_server._redis_conf_params ADD ATTRIBUTE redis_port int;
ALTER TYPE cdb_dataservices_server._redis_conf_params DROP ATTRIBUTE IF EXISTS sentinel_host;
ALTER TYPE cdb_dataservices_server._redis_conf_params DROP ATTRIBUTE IF EXISTS sentinel_port;

-- Get the Redis configuration from the _conf table --
CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_redis_conf_v2(config_key text)
RETURNS cdb_dataservices_server._redis_conf_params AS $$
    conf_query = "SELECT cartodb.CDB_Conf_GetConf('{0}') as conf".format(config_key)
    conf = plpy.execute(conf_query)[0]['conf']
    if conf is None:
      plpy.error("There is no redis configuration defined")
    else:
      import json
      params = json.loads(conf)
      redis_conf_params = {
        "redis_host": params['redis_host'],
        "redis_port": params['redis_port'],
        "timeout": params['timeout'],
        "redis_db": params['redis_db']
      }
      if "sentinel_master_id" in params:
        redis_conf_params["sentinel_master_id"] = params["sentinel_master_id"]
      else:
        redis_conf_params["sentinel_master_id"] = None

      return redis_conf_params
$$ LANGUAGE plpythonu;

-- Get the connection to redis from cache or create a new one
CREATE OR REPLACE FUNCTION cdb_dataservices_server._connect_to_redis(user_id text)
RETURNS boolean AS $$
  cache_key = "redis_connection_{0}".format(user_id)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.tools import RedisConnection
    metadata_config_params = plpy.execute("""select c.sentinel_master_id, c.redis_host, 
        c.redis_port, c.timeout, c.redis_db
        from cdb_dataservices_server._get_redis_conf_v2('redis_metadata_config') c;""")[0]
    metrics_config_params = plpy.execute("""select c.sentinel_master_id, c.redis_host, 
        c.redis_port, c.timeout, c.redis_db
        from cdb_dataservices_server._get_redis_conf_v2('redis_metrics_config') c;""")[0]
    redis_metadata_connection = RedisConnection(metadata_config_params['sentinel_master_id'],
        metadata_config_params['redis_host'],
        metadata_config_params['redis_port'],
        timeout=metadata_config_params['timeout'],
        redis_db=metadata_config_params['redis_db']).redis_connection()
    redis_metrics_connection = RedisConnection(metrics_config_params['sentinel_master_id'],
        metrics_config_params['redis_host'],
        metrics_config_params['redis_port'],
        timeout=metrics_config_params['timeout'],
        redis_db=metrics_config_params['redis_db']).redis_connection()
    GD[cache_key] = {
      'redis_metadata_connection': redis_metadata_connection,
      'redis_metrics_connection': redis_metrics_connection,
    }
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER;

-- Mapzen routing integration

CREATE TYPE cdb_dataservices_server.simple_route AS (
    shape geometry(LineString,4326),
    length real,
    duration integer
);

-- Get the Redis configuration from the _conf table --
CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_routing_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_routing_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    import json
    from cartodb_services.metrics import RoutingConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    mapzen_conf_json = plpy.execute("SELECT cartodb.CDB_Conf_GetConf('mapzen_conf') as mapzen_conf", 1)[0]['mapzen_conf']
    if not mapzen_conf_json:
      mapzen_app_key = None
    else:
      mapzen_conf = json.loads(mapzen_conf_json)
      mapzen_app_key = mapzen_conf['routing_app_key']
    routing_config = RoutingConfig(redis_conn, username, orgname, mapzen_app_key)
    GD[cache_key] = routing_config
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_route_point_to_point(
  username TEXT,
  orgname TEXT,
  origin geometry(Point, 4326),
  destination geometry(Point, 4326),
  mode TEXT,
  options text[] DEFAULT ARRAY[]::text[],
  units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_server.simple_route AS $$
  import json
  from cartodb_services.mapzen import MapzenRouting, MapzenRoutingResponse
  from cartodb_services.mapzen.types import polyline_to_linestring
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Coordinate

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_routing_config = GD["user_routing_config_{0}".format(username)]

  quota_service = QuotaService(user_routing_config, redis_conn)

  try:
    client = MapzenRouting(user_routing_config.mapzen_app_key)

    orig_lat = plpy.execute("SELECT ST_Y('%s') AS lat" % origin)[0]['lat']
    orig_lon = plpy.execute("SELECT ST_X('%s') AS lon" % origin)[0]['lon']
    origin_coordinates = Coordinate(orig_lon, orig_lat)
    dest_lat = plpy.execute("SELECT ST_Y('%s') AS lat" % destination)[0]['lat']
    dest_lon = plpy.execute("SELECT ST_X('%s') AS lon" % destination)[0]['lon']
    dest_coordinates = Coordinate(dest_lon, dest_lat)

    resp = client.calculate_route_point_to_point(origin_coordinates, dest_coordinates, mode, options, units)

    if resp:
      shape_linestring = polyline_to_linestring(resp.shape)
      quota_service.increment_success_geocoder_use()
      return [shape_linestring, resp.length, resp.duration]
    else:
      quota_service.increment_empty_geocoder_use()
  except BaseException as e:
    import sys, traceback
    type_, value_, traceback_ = sys.exc_info()
    quota_service.increment_failed_geocoder_use()
    error_msg = 'There was an error trying to obtain route using mapzen provider: {0}'.format(e)
    plpy.notice(traceback.format_tb(traceback_))
    plpy.error(error_msg)
  finally:
    quota_service.increment_total_geocoder_use()
$$ LANGUAGE plpythonu SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_route_point_to_point(
  username TEXT,
  orgname TEXT,
  origin geometry(Point, 4326),
  destination geometry(Point, 4326),
  mode TEXT,
  options text[] DEFAULT ARRAY[]::text[],
  units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_server.simple_route AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_routing_config = GD["user_routing_config_{0}".format(username)]

  mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_route_point_to_point($1, $2, $3, $4, $5, $6, $7) as route;", ["text", "text", "geometry(Point, 4326)", "geometry(Point, 4326)", "text", "text[]", "text"])
  result = plpy.execute(mapzen_plan, [username, orgname, origin, destination, mode, options, units])
  return [result[0]['shape'],result[0]['length'], result[0]['duration']]
$$ LANGUAGE plpythonu;
