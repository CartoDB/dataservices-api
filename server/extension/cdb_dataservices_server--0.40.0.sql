--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION cdb_dataservices_server" to load this file. \quit
CREATE TYPE cdb_dataservices_server.simple_route AS (
    shape geometry(LineString,4326),
    length real,
    duration integer
);

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapbox_route_with_waypoints(
  username TEXT,
  orgname TEXT,
  waypoints geometry(Point, 4326)[],
  mode TEXT,
  options text[] DEFAULT ARRAY[]::text[],
  units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_server.simple_route AS $$
  from cartodb_services.tools import ServiceManager
  from cartodb_services.mapbox import MapboxRouting
  from cartodb_services.mapbox.types import TRANSPORT_MODE_TO_MAPBOX
  from cartodb_services.tools import Coordinate
  from cartodb_services.tools.polyline import polyline_to_linestring
  from cartodb_services.tools.normalize import options_to_dict
  from cartodb_services.refactor.service.mapbox_routing_config import MapboxRoutingConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('routing', MapboxRoutingConfigBuilder, username, orgname, GD)
  service_manager.assert_within_limits()

  try:
    client = MapboxRouting(service_manager.config.mapbox_api_key, service_manager.logger, service_manager.config.service_params)

    if not waypoints or len(waypoints) < 2:
      service_manager.logger.info("Empty origin or destination")
      service_manager.quota_service.increment_empty_service_use()
      return [None, None, None]

    if len(waypoints) > 25:
      service_manager.logger.info("Too many waypoints (max 25)")
      service_manager.quota_service.increment_empty_service_use()
      return [None, None, None]

    waypoint_coords = []
    for waypoint in waypoints:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % waypoint)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % waypoint)[0]['lon']
      waypoint_coords.append(Coordinate(lon,lat))

    profile = TRANSPORT_MODE_TO_MAPBOX.get(mode)
    options_dict = options_to_dict(options)
    if 'mode_type' in options_dict:
      plpy.warning('Mapbox provider doesnt support route type parameter')

    resp = client.directions(waypoint_coords, profile)
    if resp and resp.shape:
      shape_linestring = polyline_to_linestring(resp.shape)
      if shape_linestring:
        service_manager.quota_service.increment_success_service_use()
        return [shape_linestring, resp.length, int(round(resp.duration))]
      else:
        service_manager.quota_service.increment_empty_service_use()
        return [None, None, None]
    else:
      service_manager.quota_service.increment_empty_service_use()
      return [None, None, None]
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to calculate Mapbox routing', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to calculate Mapbox routing: ' + str(e))
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;


CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_tomtom_route_with_waypoints(
  username TEXT,
  orgname TEXT,
  waypoints geometry(Point, 4326)[],
  mode TEXT,
  options text[] DEFAULT ARRAY[]::text[],
  units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_server.simple_route AS $$
  from cartodb_services.tools import ServiceManager
  from cartodb_services.tomtom import TomTomRouting
  from cartodb_services.tomtom.types import TRANSPORT_MODE_TO_TOMTOM, DEFAULT_ROUTE_TYPE, MODE_TYPE_TO_TOMTOM
  from cartodb_services.tools import Coordinate
  from cartodb_services.tools.polyline import polyline_to_linestring
  from cartodb_services.tools.normalize import options_to_dict
  from cartodb_services.refactor.service.tomtom_routing_config import TomTomRoutingConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('routing', TomTomRoutingConfigBuilder, username, orgname, GD)
  service_manager.assert_within_limits()

  try:
    client = TomTomRouting(service_manager.config.tomtom_api_key, service_manager.logger, service_manager.config.service_params)

    if not waypoints or len(waypoints) < 2:
      service_manager.logger.info("Empty origin or destination")
      service_manager.quota_service.increment_empty_service_use()
      return [None, None, None]

    if len(waypoints) > 25:
      service_manager.logger.info("Too many waypoints (max 25)")
      service_manager.quota_service.increment_empty_service_use()
      return [None, None, None]

    waypoint_coords = []
    for waypoint in waypoints:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % waypoint)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % waypoint)[0]['lon']
      waypoint_coords.append(Coordinate(lon,lat))

    profile = TRANSPORT_MODE_TO_TOMTOM.get(mode)
    route_type = DEFAULT_ROUTE_TYPE
    options_dict = options_to_dict(options)
    if 'mode_type' in options_dict:
      route_type = MODE_TYPE_TO_TOMTOM.get(options_dict['mode_type'])

    resp = client.directions(waypoint_coords, profile=profile, route_type=route_type)
    if resp and resp.shape:
      shape_linestring = polyline_to_linestring(resp.shape)
      if shape_linestring:
        service_manager.quota_service.increment_success_service_use()
        return [shape_linestring, resp.length, int(round(resp.duration))]
      else:
        service_manager.quota_service.increment_empty_service_use()
        return [None, None, None]
    else:
      service_manager.quota_service.increment_empty_service_use()
      return [None, None, None]
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to calculate TomTom routing', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to calculate TomTom routing: ' + str(e))
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_route_with_waypoints(
  username TEXT,
  orgname TEXT,
  waypoints geometry(Point, 4326)[],
  mode TEXT,
  options text[] DEFAULT ARRAY[]::text[],
  units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_server.simple_route AS $$
  import json
  from cartodb_services.mapzen import MapzenRouting, MapzenRoutingResponse
  from cartodb_services.mapzen.types import polyline_to_linestring
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Coordinate
  from cartodb_services.tools import Logger,LoggerConfig

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_routing_config = GD["user_routing_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  quota_service = QuotaService(user_routing_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
    client = MapzenRouting(user_routing_config.mapzen_api_key, logger, user_routing_config.mapzen_service_params)

    if not waypoints or len(waypoints) < 2:
      logger.info("Empty origin or destination")
      quota_service.increment_empty_service_use()
      return [None, None, None]

    waypoint_coords = []
    for waypoint in waypoints:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % waypoint)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % waypoint)[0]['lon']
      waypoint_coords.append(Coordinate(lon,lat))

    resp = client.calculate_route_point_to_point(waypoint_coords, mode, options, units)
    if resp and resp.shape:
      shape_linestring = polyline_to_linestring(resp.shape)
      if shape_linestring:
        quota_service.increment_success_service_use()
        return [shape_linestring, resp.length, resp.duration]
      else:
        quota_service.increment_empty_service_use()
        return [None, None, None]
    else:
      quota_service.increment_empty_service_use()
      return [None, None, None]
  except BaseException as e:
    import sys
    quota_service.increment_failed_service_use()
    logger.error('Error trying to calculate mapzen routing', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to calculate mapzen routing')
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_route_point_to_point(
  username TEXT,
  orgname TEXT,
  origin geometry(Point, 4326),
  destination geometry(Point, 4326),
  mode TEXT,
  options text[] DEFAULT ARRAY[]::text[],
  units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_server.simple_route AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_routing_config = GD["user_routing_config_{0}".format(username)]
  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  params = {'username': username, 'orgname': orgname, 'origin': origin, 'destination': destination, 'mode': mode, 'options': options, 'units': units}

  with metrics('cdb_route_with_point', user_routing_config, logger, params):
    waypoints = [origin, destination]

    if user_routing_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_route_with_waypoints($1, $2, $3, $4, $5, $6) as route;", ["text", "text", "geometry(Point, 4326)[]", "text", "text[]", "text"])
      result = plpy.execute(mapzen_plan, [username, orgname, waypoints, mode, options, units])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    elif user_routing_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapbox_route_with_waypoints($1, $2, $3, $4, $5, $6) as route;", ["text", "text", "geometry(Point, 4326)[]", "text", "text[]", "text"])
      result = plpy.execute(mapbox_plan, [username, orgname, waypoints, mode, options, units])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    elif user_routing_config.tomtom_provider:
      tomtom_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_tomtom_route_with_waypoints($1, $2, $3, $4, $5, $6) as route;", ["text", "text", "geometry(Point, 4326)[]", "text", "text[]", "text"])
      result = plpy.execute(tomtom_plan, [username, orgname, waypoints, mode, options, units])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    else:
      raise Exception('Requested routing method is not available')
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;


CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_route_with_waypoints(
  username TEXT,
  orgname TEXT,
  waypoints geometry(Point, 4326)[],
  mode TEXT,
  options text[] DEFAULT ARRAY[]::text[],
  units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_server.simple_route AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_routing_config = GD["user_routing_config_{0}".format(username)]
  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  params = {'username': username, 'orgname': orgname, 'waypoints': waypoints, 'mode': mode, 'options': options, 'units': units}

  with metrics('cdb_route_with_waypoints', user_routing_config, logger, params):
    if user_routing_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_route_with_waypoints($1, $2, $3, $4, $5, $6) as route;", ["text", "text", "geometry(Point, 4326)[]", "text", "text[]", "text"])
      result = plpy.execute(mapzen_plan, [username, orgname, waypoints, mode, options, units])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    elif user_routing_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapbox_route_with_waypoints($1, $2, $3, $4, $5, $6) as route;", ["text", "text", "geometry(Point, 4326)[]", "text", "text[]", "text"])
      result = plpy.execute(mapbox_plan, [username, orgname, waypoints, mode, options, units])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    elif user_routing_config.tomtom_provider:
      tomtom_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_tomtom_route_with_waypoints($1, $2, $3, $4, $5, $6) as route;", ["text", "text", "geometry(Point, 4326)[]", "text", "text[]", "text"])
      result = plpy.execute(tomtom_plan, [username, orgname, waypoints, mode, options, units])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    else:
      raise Exception('Requested routing method is not available')
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;
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
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;
CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_logger_config()
RETURNS boolean AS $$
  cache_key = "logger_config"
  if cache_key in GD:
    return False
  else:
    from cartodb_services.tools import LoggerConfig
    logger_config = LoggerConfig(plpy)
    GD[cache_key] = logger_config
    return True
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;

-- This is done in order to avoid an undesired depedency on cartodb extension
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_conf_getconf(input_key text)
RETURNS JSON AS $$
    SELECT VALUE FROM cartodb.cdb_conf WHERE key = input_key;
$$ LANGUAGE SQL SECURITY DEFINER STABLE PARALLEL SAFE;

CREATE OR REPLACE
FUNCTION cdb_dataservices_server.CDB_Conf_SetConf(key text, value JSON)
    RETURNS void AS $$
BEGIN
    PERFORM cdb_dataservices_server.CDB_Conf_RemoveConf(key);
    EXECUTE 'INSERT INTO cartodb.CDB_CONF (KEY, VALUE) VALUES ($1, $2);' USING key, value;
END
$$ LANGUAGE PLPGSQL SECURITY DEFINER VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE
FUNCTION cdb_dataservices_server.CDB_Conf_RemoveConf(key text)
    RETURNS void AS $$
BEGIN
    EXECUTE 'DELETE FROM cartodb.CDB_CONF WHERE KEY = $1;' USING key;
END
$$ LANGUAGE PLPGSQL SECURITY DEFINER VOLATILE PARALLEL UNSAFE ;


CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_geocoder_config(username text, orgname text, provider text DEFAULT NULL)
RETURNS boolean AS $$
  cache_key = "user_geocoder_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import GeocoderConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    geocoder_config = GeocoderConfig(redis_conn, plpy, username, orgname, provider)
    GD[cache_key] = geocoder_config
    return True
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_internal_geocoder_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_internal_geocoder_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import InternalGeocoderConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    geocoder_config = InternalGeocoderConfig(redis_conn, plpy, username, orgname)
    GD[cache_key] = geocoder_config
    return True
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_isolines_routing_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_isolines_routing_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import IsolinesRoutingConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    isolines_routing_config = IsolinesRoutingConfig(redis_conn, plpy, username, orgname)
    GD[cache_key] = isolines_routing_config
    return True
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_routing_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_routing_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import RoutingConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    routing_config = RoutingConfig(redis_conn, plpy, username, orgname)
    GD[cache_key] = routing_config
    return True
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type inner join pg_namespace ON (pg_type.typnamespace = pg_namespace.oid)
                 WHERE pg_type.typname = 'service_type'
                 AND pg_namespace.nspname = 'cdb_dataservices_server') THEN
    CREATE TYPE cdb_dataservices_server.service_type AS ENUM (
      'isolines',
      'hires_geocoder',
      'routing'
    );
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type inner join pg_namespace ON (pg_type.typnamespace = pg_namespace.oid)
                 WHERE pg_type.typname = 'service_quota_info'
                 AND pg_namespace.nspname = 'cdb_dataservices_server') THEN
    CREATE TYPE cdb_dataservices_server.service_quota_info AS (
      service cdb_dataservices_server.service_type,
      monthly_quota NUMERIC,
      used_quota NUMERIC,
      soft_limit BOOLEAN,
      provider TEXT
    );
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type inner join pg_namespace ON (pg_type.typnamespace = pg_namespace.oid)
                 WHERE pg_type.typname = 'service_quota_info_batch'
                 AND pg_namespace.nspname = 'cdb_dataservices_server') THEN
    CREATE TYPE cdb_dataservices_server.service_quota_info_batch AS (
      service cdb_dataservices_server.service_type,
      monthly_quota NUMERIC,
      used_quota NUMERIC,
      soft_limit BOOLEAN,
      provider TEXT,
      max_batch_size NUMERIC
    );
  END IF;
END $$;


CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_quota_info(
  username TEXT,
  orgname TEXT)
RETURNS SETOF cdb_dataservices_server.service_quota_info AS $$
  from cartodb_services.metrics.user import UserMetricsService
  from datetime import date

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']

  today = date.today()
  ret = []

  #-- Isolines
  service = 'isolines'
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
  user_service = UserMetricsService(user_isolines_config, redis_conn)

  monthly_quota = user_isolines_config.isolines_quota
  used_quota = user_service.used_quota(user_isolines_config.service_type, today)
  soft_limit = user_isolines_config.soft_isolines_limit
  provider = user_isolines_config.provider
  ret += [[service, monthly_quota, used_quota, soft_limit, provider]]

  #-- Hires Geocoder
  service = 'hires_geocoder'
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]
  user_service = UserMetricsService(user_geocoder_config, redis_conn)

  monthly_quota = user_geocoder_config.geocoding_quota
  used_quota = user_service.used_quota(user_geocoder_config.service_type, today)
  soft_limit = user_geocoder_config.soft_geocoding_limit
  provider = user_geocoder_config.provider
  ret += [[service, monthly_quota, used_quota, soft_limit, provider]]

  #-- Routing
  service = 'routing'
  plpy.execute("SELECT cdb_dataservices_server._get_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_routing_config = GD["user_routing_config_{0}".format(username)]
  user_service = UserMetricsService(user_routing_config, redis_conn)

  monthly_quota = user_routing_config.monthly_quota
  used_quota = user_service.used_quota(user_routing_config.service_type, today)
  soft_limit = user_routing_config.soft_limit
  provider = user_routing_config.provider
  ret += [[service, monthly_quota, used_quota, soft_limit, provider]]

  return ret
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;


CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_quota_info_batch(
  username TEXT,
  orgname TEXT)
RETURNS SETOF cdb_dataservices_server.service_quota_info_batch AS $$
  from cartodb_services.bulk_geocoders import BATCH_GEOCODER_CLASS_BY_PROVIDER
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  sqi = plpy.execute("SELECT * from cdb_dataservices_server.cdb_service_quota_info({0},{1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))

  ret = []
  for info in sqi:
      if info['service'] == 'hires_geocoder':
          provider = info['provider']
          batch_geocoder_class = BATCH_GEOCODER_CLASS_BY_PROVIDER.get(provider, None)
          if batch_geocoder_class and hasattr(batch_geocoder_class, 'MAX_BATCH_SIZE'):
              max_batch_size = batch_geocoder_class.MAX_BATCH_SIZE
          else:
              max_batch_size = 1

          info['max_batch_size'] = max_batch_size
      else:
          info['max_batch_size'] = 1

      ret += [[info['service'], info['monthly_quota'], info['used_quota'], info['soft_limit'], info['provider'], info['max_batch_size']]]

  return ret
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_enough_quota(
  username TEXT,
  orgname TEXT,
  service_ TEXT,
  input_size NUMERIC)
returns BOOLEAN AS $$
  DECLARE
    params cdb_dataservices_server.service_quota_info;
  BEGIN
    SELECT * INTO params
      FROM cdb_dataservices_server.cdb_service_quota_info(username, orgname) AS p
      WHERE p.service = service_::cdb_dataservices_server.service_type;
    RETURN params.soft_limit OR ((params.used_quota + input_size) <= params.monthly_quota);
  END
$$ LANGUAGE plpgsql STABLE PARALLEL RESTRICTED;
-- Geocodes a street address given a searchtext and a state and/or country

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger,LoggerConfig
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]
  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  params = {'username': username, 'orgname': orgname, 'searchtext': searchtext, 'city': city, 'state_province': state_province, 'country': country}

  with metrics('cdb_geocode_street_point', user_geocoder_config, logger, params):
    if user_geocoder_config.heremaps_geocoder:
      here_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_here_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
      return plpy.execute(here_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
    elif user_geocoder_config.google_geocoder:
      google_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_google_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
      return plpy.execute(google_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
    elif user_geocoder_config.mapzen_geocoder:
      mapzen_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapzen_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
      return plpy.execute(mapzen_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
    elif user_geocoder_config.mapbox_geocoder:
      mapbox_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapbox_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
      return plpy.execute(mapbox_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
    elif user_geocoder_config.tomtom_geocoder:
      tomtom_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_tomtom_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
      return plpy.execute(tomtom_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
    elif user_geocoder_config.geocodio_geocoder:
      geocodio_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocodio_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
      return plpy.execute(geocodio_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
    else:
      raise Exception('Requested geocoder is not available')

$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;


CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_here_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  if user_geocoder_config.heremaps_geocoder:
    here_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_here_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
    return plpy.execute(here_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
  else:
    raise Exception('Here geocoder is not available for your account.')

$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_google_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  if user_geocoder_config.google_geocoder:
    google_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_google_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
    return plpy.execute(google_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
  else:
    raise Exception('Google geocoder is not available for your account.')

$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapzen_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  # The configuration is retrieved but no checks are performed on it
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  mapzen_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapzen_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
  return plpy.execute(mapzen_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']

$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapbox_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  # The configuration is retrieved but no checks are performed on it
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  mapbox_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapbox_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
  return plpy.execute(mapbox_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']

$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_tomtom_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  # The configuration is retrieved but no checks are performed on it
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  tomtom_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_tomtom_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
  return plpy.execute(tomtom_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']

$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocodio_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  # The configuration is retrieved but no checks are performed on it
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  geocodio_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocodio_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
  return plpy.execute(geocodio_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']

$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_here_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.tools import LegacyServiceManager
  from cartodb_services.tools import QuotaExceededException
  from cartodb_services.here import HereMapsGeocoder

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  service_manager = LegacyServiceManager('geocoder', username, orgname, GD)

  try:
    service_manager.assert_within_limits()
    geocoder = HereMapsGeocoder(service_manager.config.heremaps_app_id, service_manager.config.heremaps_app_code, service_manager.logger, service_manager.config.heremaps_service_params)
    coordinates = geocoder.geocode(searchtext=searchtext, city=city, state=state_province, country=country)
    if coordinates:
      service_manager.quota_service.increment_success_service_use()
      plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
      point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]
      return point['st_setsrid']
    else:
      service_manager.quota_service.increment_empty_service_use()
      return None
  except QuotaExceededException as qe:
    service_manager.quota_service.increment_failed_service_use()
    return None
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to geocode street point using here maps', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using here maps')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_google_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.tools import LegacyServiceManager, QuotaExceededException
  from cartodb_services.google import GoogleMapsGeocoder

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  service_manager = LegacyServiceManager('geocoder', username, orgname, GD)

  try:
    service_manager.assert_within_limits(quota=False)
    geocoder = GoogleMapsGeocoder(service_manager.config.google_client_id, service_manager.config.google_api_key, service_manager.logger)
    coordinates = geocoder.geocode(searchtext=searchtext, city=city, state=state_province, country=country)
    if coordinates:
      service_manager.quota_service.increment_success_service_use()
      plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
      point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]
      return point['st_setsrid']
    else:
      service_manager.quota_service.increment_empty_service_use()
      return None
  except QuotaExceededException as qe:
    service_manager.quota_service.increment_failed_service_use()
    return None
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to geocode street point using google maps', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using google maps')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.tools import ServiceManager, QuotaExceededException
  from cartodb_services.mapzen import MapzenGeocoder
  from cartodb_services.tools.country import country_to_iso3
  from cartodb_services.refactor.service.mapzen_geocoder_config import MapzenGeocoderConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('geocoder', MapzenGeocoderConfigBuilder, username, orgname)

  try:
    service_manager.assert_within_limits()
    geocoder = MapzenGeocoder(service_manager.config.mapzen_api_key, service_manager.logger, service_manager.config.service_params)
    country_iso3 = None
    if country:
      country_iso3 = country_to_iso3(country)
    coordinates = geocoder.geocode(searchtext=searchtext, city=city,
                                   state_province=state_province,
                                   country=country_iso3, search_type='address')
    if coordinates:
      service_manager.quota_service.increment_success_service_use()
      plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
      point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]
      return point['st_setsrid']
    else:
      service_manager.quota_service.increment_empty_service_use()
      return None
  except QuotaExceededException as qe:
    service_manager.quota_service.increment_failed_service_use()
    return None
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to geocode street point using mapzen', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using mapzen')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapbox_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from iso3166 import countries
  from cartodb_services.tools import ServiceManager, QuotaExceededException
  from cartodb_services.mapbox import MapboxGeocoder
  from cartodb_services.tools.country import country_to_iso3
  from cartodb_services.refactor.service.mapbox_geocoder_config import MapboxGeocoderConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('geocoder', MapboxGeocoderConfigBuilder, username, orgname, GD)

  try:
    service_manager.assert_within_limits()
    geocoder = MapboxGeocoder(service_manager.config.mapbox_api_key, service_manager.logger, service_manager.config.service_params)

    country_iso3166 = None
    if country:
      country_iso3 = country_to_iso3(country)
      if country_iso3:
        country_iso3166 = countries.get(country_iso3).alpha2.lower()

    coordinates = geocoder.geocode(searchtext=searchtext, city=city,
                                   state_province=state_province,
                                   country=country_iso3166)
    if coordinates:
      service_manager.quota_service.increment_success_service_use()
      plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
      point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]
      return point['st_setsrid']
    else:
      service_manager.quota_service.increment_empty_service_use()
      return None
  except QuotaExceededException as qe:
    service_manager.quota_service.increment_failed_service_use()
    return None
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to geocode street point using Mapbox', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using Mapbox')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_tomtom_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.tools import ServiceManager, QuotaExceededException
  from cartodb_services.tomtom import TomTomGeocoder
  from cartodb_services.refactor.service.tomtom_geocoder_config import TomTomGeocoderConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('geocoder', TomTomGeocoderConfigBuilder, username, orgname, GD)

  try:
    service_manager.assert_within_limits()
    geocoder = TomTomGeocoder(service_manager.config.tomtom_api_key, service_manager.logger, service_manager.config.service_params)

    coordinates = geocoder.geocode(searchtext=searchtext, city=city,
                                   state_province=state_province,
                                   country=country)
    if coordinates:
      service_manager.quota_service.increment_success_service_use()
      plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
      point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]
      return point['st_setsrid']
    else:
      service_manager.quota_service.increment_empty_service_use()
      return None
  except QuotaExceededException as qe:
    service_manager.quota_service.increment_failed_service_use()
    return None
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to geocode street point using TomTom', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using TomTom')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_geocodio_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from iso3166 import countries
  from cartodb_services.tools import ServiceManager, QuotaExceededException
  from cartodb_services.geocodio import GeocodioGeocoder
  from cartodb_services.tools.country import country_to_iso3
  from cartodb_services.refactor.service.geocodio_geocoder_config import GeocodioGeocoderConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('geocoder', GeocodioGeocoderConfigBuilder, username, orgname, GD)

  try:
    service_manager.assert_within_limits()
    geocoder = GeocodioGeocoder(service_manager.config.geocodio_api_key, service_manager.logger, service_manager.config.service_params)

    country_iso3166 = None
    if country:
      country_iso3 = country_to_iso3(country)
      if country_iso3:
        country_iso3166 = countries.get(country_iso3).alpha2.lower()

    coordinates = geocoder.geocode(searchtext=searchtext, city=city,
                                   state_province=state_province,
                                   country=country_iso3166)
    if coordinates:
      service_manager.quota_service.increment_success_service_use()
      plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
      point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]
      return point['st_setsrid']
    else:
      service_manager.quota_service.increment_empty_service_use()
      return None
  except QuotaExceededException as qe:
    service_manager.quota_service.increment_failed_service_use()
    return None
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to geocode street point using Geocodio', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using Geocodio')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_get_rate_limit(
  username TEXT,
  orgname TEXT,
  service TEXT)
RETURNS JSON AS $$
  import json
  from cartodb_services.config import ServiceConfiguration, RateLimitsConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_config = ServiceConfiguration(service, username, orgname)
  rate_limit_config = RateLimitsConfigBuilder(service_config.server, service_config.user, service_config.org, service=service, username=username, orgname=orgname).get()
  if rate_limit_config.is_limited():
      return json.dumps({'limit': rate_limit_config.limit, 'period': rate_limit_config.period})
  else:
      return None
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_set_user_rate_limit(
  username TEXT,
  orgname TEXT,
  service TEXT,
  rate_limit_json JSON)
RETURNS VOID AS $$
  import json
  from cartodb_services.config import RateLimitsConfig, RateLimitsConfigSetter

  import cartodb_services
  cartodb_services.init(plpy, GD)

  config_setter = RateLimitsConfigSetter(service=service, username=username, orgname=orgname)
  if rate_limit_json:
      rate_limit = json.loads(rate_limit_json)
      limit = rate_limit.get('limit', None)
      period = rate_limit.get('period', None)
  else:
      limit = None
      period = None
  config = RateLimitsConfig(service=service, username=username, limit=limit, period=period)
  config_setter.set_user_rate_limits(config)
$$ LANGUAGE @@plpythonu@@ VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_set_org_rate_limit(
  username TEXT,
  orgname TEXT,
  service TEXT,
  rate_limit_json JSON)
RETURNS VOID AS $$
  import json
  from cartodb_services.config import RateLimitsConfig, RateLimitsConfigSetter

  import cartodb_services
  cartodb_services.init(plpy, GD)

  config_setter = RateLimitsConfigSetter(service=service, username=username, orgname=orgname)
  if rate_limit_json:
      rate_limit = json.loads(rate_limit_json)
      limit = rate_limit.get('limit', None)
      period = rate_limit.get('period', None)
  else:
      limit = None
      period = None
  config = RateLimitsConfig(service=service, username=username, limit=limit, period=period)
  config_setter.set_org_rate_limits(config)
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_set_server_rate_limit(
  username TEXT,
  orgname TEXT,
  service TEXT,
  rate_limit_json JSON)
RETURNS VOID AS $$
  import json
  from cartodb_services.config import RateLimitsConfig, RateLimitsConfigSetter

  import cartodb_services
  cartodb_services.init(plpy, GD)

  config_setter = RateLimitsConfigSetter(service=service, username=username, orgname=orgname)
  if rate_limit_json:
      rate_limit = json.loads(rate_limit_json)
      limit = rate_limit.get('limit', None)
      period = rate_limit.get('period', None)
  else:
      limit = None
      period = None
  config = RateLimitsConfig(service=service, username=username, limit=limit, period=period)
  config_setter.set_server_rate_limits(config)
$$ LANGUAGE @@plpythonu@@ VOLATILE PARALLEL UNSAFE;
-- TODO: could cartodb_id be replaced by rowid, maybe needing extra care for offset?
CREATE TYPE cdb_dataservices_server.geocoding AS (
    cartodb_id integer,
    the_geom geometry(Point,4326),
    metadata jsonb
);

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_bulk_geocode_street_point(username TEXT, orgname TEXT, searches jsonb)
RETURNS SETOF cdb_dataservices_server.geocoding AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger
  import json

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']

  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  params = {'username': username, 'orgname': orgname, 'searches': json.loads(searches)}

  with metrics('cdb_bulk_geocode_street_point', user_geocoder_config, logger, params):
    if user_geocoder_config.google_geocoder:
      provider_function = "_cdb_bulk_google_geocode_street_point";
    elif user_geocoder_config.heremaps_geocoder:
      provider_function = "_cdb_bulk_heremaps_geocode_street_point";
    elif user_geocoder_config.tomtom_geocoder:
      provider_function = "_cdb_bulk_tomtom_geocode_street_point";
    elif user_geocoder_config.mapbox_geocoder:
      provider_function = "_cdb_bulk_mapbox_geocode_street_point";
    elif user_geocoder_config.geocodio_geocoder:
      provider_function = "_cdb_bulk_geocodio_geocode_street_point";
    else:
      raise Exception('Requested geocoder is not available')

    plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.{}($1, $2, $3); ".format(provider_function), ["text", "text", "jsonb"])
    return plpy.execute(plan, [username, orgname, searches])

$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_bulk_google_geocode_street_point(username TEXT, orgname TEXT, searches jsonb)
RETURNS SETOF cdb_dataservices_server.geocoding AS $$
  from cartodb_services import run_street_point_geocoder
  from cartodb_services.tools import LegacyServiceManager
  from cartodb_services.google import GoogleMapsBulkGeocoder

  service_manager = LegacyServiceManager('geocoder', username, orgname, GD)
  geocoder = GoogleMapsBulkGeocoder(service_manager.config.google_client_id, service_manager.config.google_api_key, service_manager.logger)
  return run_street_point_geocoder(plpy, GD, geocoder, service_manager, username, orgname, searches)
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_bulk_heremaps_geocode_street_point(username TEXT, orgname TEXT, searches jsonb)
RETURNS SETOF cdb_dataservices_server.geocoding AS $$
  from cartodb_services import run_street_point_geocoder
  from cartodb_services.tools import LegacyServiceManager
  from cartodb_services.here import HereMapsBulkGeocoder

  service_manager = LegacyServiceManager('geocoder', username, orgname, GD)
  geocoder = HereMapsBulkGeocoder(service_manager.config.heremaps_app_id, service_manager.config.heremaps_app_code, service_manager.logger, service_manager.config.heremaps_service_params)
  return run_street_point_geocoder(plpy, GD, geocoder, service_manager, username, orgname, searches)
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_bulk_tomtom_geocode_street_point(username TEXT, orgname TEXT, searches jsonb)
RETURNS SETOF cdb_dataservices_server.geocoding AS $$
  from cartodb_services import run_street_point_geocoder
  from cartodb_services.tools import ServiceManager
  from cartodb_services.refactor.service.tomtom_geocoder_config import TomTomGeocoderConfigBuilder
  from cartodb_services.tomtom import TomTomBulkGeocoder
  from cartodb_services.tools import Logger
  import cartodb_services
  cartodb_services.init(plpy, GD)

  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  service_manager = ServiceManager('geocoder', TomTomGeocoderConfigBuilder, username, orgname, GD)
  geocoder = TomTomBulkGeocoder(service_manager.config.tomtom_api_key, service_manager.logger, service_manager.config.service_params)
  return run_street_point_geocoder(plpy, GD, geocoder, service_manager, username, orgname, searches)
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_bulk_mapbox_geocode_street_point(username TEXT, orgname TEXT, searches jsonb)
RETURNS SETOF cdb_dataservices_server.geocoding AS $$
  from cartodb_services import run_street_point_geocoder
  from cartodb_services.tools import ServiceManager
  from cartodb_services.refactor.service.mapbox_geocoder_config import MapboxGeocoderConfigBuilder
  from cartodb_services.mapbox import MapboxBulkGeocoder
  from cartodb_services.tools import Logger
  import cartodb_services
  cartodb_services.init(plpy, GD)

  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  service_manager = ServiceManager('geocoder', MapboxGeocoderConfigBuilder, username, orgname, GD)
  geocoder = MapboxBulkGeocoder(service_manager.config.mapbox_api_key, service_manager.logger, service_manager.config.service_params)
  return run_street_point_geocoder(plpy, GD, geocoder, service_manager, username, orgname, searches)
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_bulk_geocodio_geocode_street_point(username TEXT, orgname TEXT, searches jsonb)
RETURNS SETOF cdb_dataservices_server.geocoding AS $$
  from cartodb_services import run_street_point_geocoder
  from cartodb_services.tools import ServiceManager
  from cartodb_services.refactor.service.geocodio_geocoder_config import GeocodioGeocoderConfigBuilder
  from cartodb_services.geocodio import GeocodioBulkGeocoder
  from cartodb_services.tools import Logger
  import cartodb_services
  cartodb_services.init(plpy, GD)

  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  service_manager = ServiceManager('geocoder', GeocodioGeocoderConfigBuilder, username, orgname, GD)
  geocoder = GeocodioBulkGeocoder(service_manager.config.geocodio_api_key, service_manager.logger, service_manager.config.service_params)
  return run_street_point_geocoder(plpy, GD, geocoder, service_manager, username, orgname, searches)
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_admin0_polygon(username text, orgname text, country_name text)
RETURNS Geometry AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.metrics import InternalGeocoderConfig
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)

  params = {'username': username, 'orgname': orgname, 'country_name': country_name}

  with metrics('cdb_geocode_admin0_polygon', user_geocoder_config, logger, params):
    try:
      plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_admin0_polygon(trim($1)) AS mypolygon", ["text"])
      rv = plpy.execute(plan, [country_name], 1)
      result = rv[0]["mypolygon"]
      if result:
        quota_service.increment_success_service_use()
        return result
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode admin0 polygon', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode admin0 polygon')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;


--------------------------------------------------------------------------------

-- Implementation of the server extension
-- Note: these functions depend on the cdb_geocoder extension
CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_geocode_admin0_polygon(country_name text)
RETURNS Geometry AS $$
  DECLARE
    ret Geometry;
  BEGIN
    SELECT n.the_geom as geom INTO ret
      FROM (SELECT q, lower(regexp_replace(q, '[^a-zA-Z\u00C0-\u00ff]+', '', 'g'))::text x
        FROM (SELECT country_name q) g) d
      LEFT OUTER JOIN admin0_synonyms s ON name_ = d.x
      LEFT OUTER JOIN ne_admin0_v3 n ON s.adm0_a3 = n.adm0_a3 GROUP BY d.q, n.the_geom, s.adm0_a3;

    RETURN ret;
  END
$$ LANGUAGE plpgsql STABLE PARALLEL SAFE;
---- cdb_geocode_admin1_polygon(admin1_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_admin1_polygon(username text, orgname text, admin1_name text)
RETURNS Geometry AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.metrics import InternalGeocoderConfig
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)

  params = {'username': username, 'orgname': orgname, 'admin1_name': admin1_name}

  with metrics('cdb_geocode_admin1_polygon', user_geocoder_config, logger, params):
    try:
      plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_admin1_polygon(trim($1)) AS mypolygon", ["text"])
      rv = plpy.execute(plan, [admin1_name], 1)
      result = rv[0]["mypolygon"]
      if result:
        quota_service.increment_success_service_use()
        return result
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode admin1 polygon', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode admin1 polygon')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

---- cdb_geocode_admin1_polygon(admin1_name text, country_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_admin1_polygon(username text, orgname text, admin1_name text, country_name text)
RETURNS Geometry AS $$
    from cartodb_services.metrics import metrics
    from cartodb_services.metrics import QuotaService
    from cartodb_services.metrics import InternalGeocoderConfig
    from cartodb_services.tools import Logger,LoggerConfig

    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
    plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
    user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

    plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
    logger_config = GD["logger_config"]
    logger = Logger(logger_config)
    quota_service = QuotaService(user_geocoder_config, redis_conn)

    with metrics('cdb_geocode_admin1_polygon', user_geocoder_config, logger):
      try:
        plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_admin1_polygon(trim($1), trim($2)) AS mypolygon", ["text", "text"])
        rv = plpy.execute(plan, [admin1_name, country_name], 1)
        result = rv[0]["mypolygon"]
        if result:
          quota_service.increment_success_service_use()
          return result
        else:
          quota_service.increment_empty_service_use()
          return None
      except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to geocode admin1 polygon', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to geocode admin1 polygon')
      finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

--------------------------------------------------------------------------------

-- Implementation of the server extension
-- Note: these functions depend on the cdb_geocoder extension

---- cdb_geocode_admin1_polygon(admin1_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_geocode_admin1_polygon(admin1_name text)
RETURNS Geometry AS $$
  DECLARE
    ret Geometry;
  BEGIN
    SELECT geom INTO ret
    FROM (
      SELECT q, (
          SELECT the_geom
          FROM global_province_polygons
          WHERE d.c = ANY (synonyms)
          ORDER BY frequency DESC LIMIT 1
        ) geom
      FROM (
        SELECT
          trim(replace(lower(admin1_name),'.',' ')) c, admin1_name q
        ) d
      ) v;

    RETURN ret;
  END
$$ LANGUAGE plpgsql STABLE PARALLEL SAFE;

---- cdb_geocode_admin1_polygon(admin1_name text, country_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_geocode_admin1_polygon(admin1_name text, country_name text)
RETURNS Geometry AS $$
  DECLARE
    ret Geometry;
  BEGIN
    WITH p AS (SELECT r.c, r.q, (SELECT iso3 FROM country_decoder WHERE lower(country_name) = ANY (synonyms)) i FROM (SELECT  trim(replace(lower(admin1_name),'.',' ')) c, country_name q) r)
    SELECT
      geom INTO ret
    FROM (
      SELECT
        q, (
          SELECT the_geom
          FROM global_province_polygons
          WHERE p.c = ANY (synonyms)
          AND iso3 = p.i
          ORDER BY frequency DESC LIMIT 1
        ) geom
      FROM p) n;

    RETURN ret;
  END
$$ LANGUAGE plpgsql STABLE PARALLEL SAFE;

---- cdb_geocode_namedplace_point(city_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text)
RETURNS Geometry AS $$
  from plpy import spiexceptions
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  try:
    street_point = plpy.prepare("SELECT cdb_dataservices_server.cdb_geocode_street_point($1, $2, $3) as point;", ["text", "text", "text"])
    return plpy.execute(street_point, [username, orgname, city_name])[0]['point']
  except spiexceptions.ExternalRoutineException as e:
    import sys
    logger.error('Error geocoding namedplace using geocode street point, falling back to internal geocoder', sys.exc_info(), data={"username": username, "orgname": orgname})
    internal_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_internal_geocode_namedplace($1, $2, $3) as point;", ["text", "text", "text"])
    return plpy.execute(internal_plan, [username, orgname, city_name])[0]['point']
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

---- cdb_geocode_namedplace_point(city_name text, country_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text, country_name text)
RETURNS Geometry AS $$
  from plpy import spiexceptions
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  try:
    street_point = plpy.prepare("SELECT cdb_dataservices_server.cdb_geocode_street_point($1, $2, $3, NULL, NULL, $4) as point;", ["text", "text", "text", "text"])
    return plpy.execute(street_point, [username, orgname, city_name, country_name])[0]['point']
  except spiexceptions.ExternalRoutineException as e:
    import sys
    logger.error('Error geocoding namedplace using geocode street point, falling back to internal geocoder', sys.exc_info(), data={"username": username, "orgname": orgname})
    internal_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_internal_geocode_namedplace($1, $2, $3, NULL, $4) as point;", ["text", "text", "text", "text"])
    return plpy.execute(internal_plan, [username, orgname, city_name, country_name])[0]['point']
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

---- cdb_geocode_namedplace_point(city_name text, admin1_name text, country_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text, admin1_name text, country_name text)
RETURNS Geometry AS $$
  from plpy import spiexceptions
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  try:
    street_point = plpy.prepare("SELECT cdb_dataservices_server.cdb_geocode_street_point($1, $2, $3, NULL, $4, $5) as point;", ["text", "text", "text", "text", "text"])
    return plpy.execute(street_point, [username, orgname, city_name, admin1_name, country_name])[0]['point']
  except spiexceptions.ExternalRoutineException as e:
    import sys
    logger.error('Error geocoding namedplace using geocode street point, falling back to internal geocoder', sys.exc_info(), data={"username": username, "orgname": orgname})
    internal_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_internal_geocode_namedplace($1, $2, $3, $4, $5) as point;", ["text", "text", "text", "text", "text"])
    return plpy.execute(internal_plan, [username, orgname, city_name, admin1_name, country_name])[0]['point']
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_internal_geocode_namedplace(username text, orgname text, city_name text, admin1_name text DEFAULT NULL, country_name text DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.metrics import InternalGeocoderConfig, metrics
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)

  params = {'username': username, 'orgname': orgname, 'city_name': city_name, 'admin1_name': admin1_name, 'country_name': country_name}

  with metrics('cdb_geocode_namedplace_point', user_geocoder_config, logger, params):
    try:
      if admin1_name and country_name:
        plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_namedplace_point(trim($1), trim($2), trim($3)) AS mypoint", ["text", "text", "text"])
        rv = plpy.execute(plan, [city_name, admin1_name, country_name], 1)
      elif country_name:
        plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_namedplace_point(trim($1), trim($2)) AS mypoint", ["text", "text"])
        rv = plpy.execute(plan, [city_name, country_name], 1)
      else:
        plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_namedplace_point(trim($1)) AS mypoint", ["text"])
        rv = plpy.execute(plan, [city_name], 1)
      result = rv[0]["mypoint"]
      if result:
        quota_service.increment_success_service_use()
        return result
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode namedplace point', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode namedplace point')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

--------------------------------------------------------------------------------

-- Implementation of the server extension
-- Note: these functions depend on the cdb_geocoder extension

---- cdb_geocode_namedplace_point(city_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_geocode_namedplace_point(city_name text)
RETURNS Geometry AS $$
  DECLARE
    ret Geometry;
  BEGIN
  SELECT geom INTO ret
  FROM (
    WITH best AS (SELECT s AS q, (SELECT the_geom FROM global_cities_points_limited gp WHERE gp.lowername = lower(p.s) ORDER BY population DESC LIMIT 1) AS geom FROM (SELECT city_name as s) p),
        next AS (SELECT p.s AS q, (SELECT gp.the_geom FROM global_cities_points_limited gp, global_cities_alternates_limited ga WHERE lower(p.s) = ga.lowername AND ga.geoname_id = gp.geoname_id ORDER BY preferred DESC LIMIT 1) geom FROM (SELECT city_name as s) p WHERE p.s NOT IN (SELECT q FROM best WHERE geom IS NOT NULL))
        SELECT q, geom, TRUE AS success FROM best WHERE geom IS NOT NULL
        UNION ALL
        SELECT q, geom, CASE WHEN geom IS NULL THEN FALSE ELSE TRUE END AS success FROM next
  ) v;

    RETURN ret;
  END
$$ LANGUAGE plpgsql STABLE PARALLEL SAFE;

---- cdb_geocode_namedplace_point(city_name text, country_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_geocode_namedplace_point(city_name text, country_name text)
RETURNS Geometry AS $$
  DECLARE
    ret Geometry;
  BEGIN
  SELECT geom INTO ret
  FROM (
    WITH p AS (SELECT r.s, r.c, (SELECT iso2 FROM country_decoder WHERE lower(r.c) = ANY (synonyms)) i FROM (SELECT city_name AS s, country_name::text AS c) r),
        best AS (SELECT p.s AS q, p.c AS c, (SELECT gp.the_geom AS geom FROM global_cities_points_limited gp WHERE gp.lowername = lower(p.s) AND gp.iso2 = p.i ORDER BY population DESC LIMIT 1) AS geom FROM p),
        next AS (SELECT p.s AS q, p.c AS c, (SELECT gp.the_geom FROM global_cities_points_limited gp, global_cities_alternates_limited ga WHERE lower(p.s) = ga.lowername AND gp.iso2 = p.i AND ga.geoname_id = gp.geoname_id ORDER BY preferred DESC LIMIT 1) geom FROM p WHERE p.s NOT IN (SELECT q FROM best WHERE c = p.c AND geom IS NOT NULL))
        SELECT geom FROM best WHERE geom IS NOT NULL
        UNION ALL
        SELECT geom FROM next
   ) v;

    RETURN ret;
  END
$$ LANGUAGE plpgsql STABLE PARALLEL SAFE;

---- cdb_geocode_namedplace_point(city_name text, admin1_name text, country_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_geocode_namedplace_point(city_name text, admin1_name text, country_name text)
RETURNS Geometry AS $$
  DECLARE
    ret Geometry;
  BEGIN
  SELECT geom INTO ret
  FROM (
    WITH inputcountry AS (
        SELECT iso2 as isoTwo FROM country_decoder WHERE lower(country_name) = ANY (synonyms) LIMIT 1
        ),
    p AS (
       SELECT r.s, r.a1, (SELECT admin1 FROM admin1_decoder, inputcountry WHERE lower(r.a1) = ANY (synonyms) AND admin1_decoder.iso2 = inputcountry.isoTwo LIMIT 1) i FROM (SELECT city_name AS s, admin1_name::text AS a1) r),
       best AS (SELECT p.s AS q, p.a1 as a1, (SELECT gp.the_geom AS geom FROM global_cities_points_limited gp WHERE gp.lowername = lower(p.s) AND gp.admin1 = p.i ORDER BY population DESC LIMIT 1) AS geom FROM p),
       next AS (SELECT p.s AS q, p.a1 AS a1, (SELECT gp.the_geom FROM global_cities_points_limited gp, global_cities_alternates_limited ga WHERE lower(p.s) = ga.lowername AND ga.admin1 = p.i AND ga.geoname_id = gp.geoname_id ORDER BY preferred DESC LIMIT 1) geom FROM p WHERE p.s NOT IN (SELECT q FROM best WHERE geom IS NOT NULL))
       SELECT geom FROM best WHERE geom IS NOT NULL
       UNION ALL
       SELECT geom FROM next
   ) v;

    RETURN ret;
  END
$$ LANGUAGE plpgsql STABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_point(username text, orgname text, code text)
RETURNS Geometry AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.metrics import InternalGeocoderConfig
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)

  params = {'username': username, 'orgname': orgname, 'code': code}

  with metrics('cdb_geocode_postalcode_point', user_geocoder_config, logger, params):
    try:
      plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_postalcode_point(trim($1)) AS mypoint", ["text"])
      rv = plpy.execute(plan, [code], 1)
      result = rv[0]["mypoint"]
      if result:
        quota_service.increment_success_service_use()
        return result
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode postal code point', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode postal code point')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_point(username text, orgname text, code double precision)
RETURNS Geometry AS $$
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_point(username, orgname, code::text);
$$ LANGUAGE SQL STABLE PARALLEL RESTRICTED;


CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_point(username text, orgname text, code text, country text)
RETURNS Geometry AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.metrics import InternalGeocoderConfig
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)
  with metrics('cdb_geocode_postalcode_point', user_geocoder_config, logger):
    try:
      plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_postalcode_point(trim($1), trim($2)) AS mypoint", ["TEXT", "TEXT"])
      rv = plpy.execute(plan, [code, country], 1)
      result = rv[0]["mypoint"]
      if result:
        quota_service.increment_success_service_use()
        return result
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode postal code point', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode postal code point')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_point(username text, orgname text, code double precision, country text)
RETURNS Geometry AS $$
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_point(username, orgname, code::text, country);
$$ LANGUAGE SQL STABLE PARALLEL RESTRICTED;


CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_polygon(username text, orgname text, code text)
RETURNS Geometry AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.metrics import InternalGeocoderConfig
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)
  with metrics('cdb_geocode_postalcode_point', user_geocoder_config, logger):
    try:
      plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_postalcode_polygon(trim($1)) AS mypolygon", ["text"])
      rv = plpy.execute(plan, [code], 1)
      result = rv[0]["mypolygon"]
      if result:
        quota_service.increment_success_service_use()
        return result
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode postal code polygon', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode postal code polygon')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_polygon(username text, orgname text, code double precision)
RETURNS Geometry AS $$
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_polygon(username, orgname, code::text)
$$ LANGUAGE SQL STABLE PARALLEL RESTRICTED;



CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_polygon(username text, orgname text, code text, country text)
RETURNS Geometry AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.metrics import InternalGeocoderConfig
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)
  with metrics('cdb_geocode_postalcode_point', user_geocoder_config, logger):
    try:
      plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_postalcode_polygon(trim($1), trim($2)) AS mypolygon", ["TEXT", "TEXT"])
      rv = plpy.execute(plan, [code, country], 1)
      result = rv[0]["mypolygon"]
      if result:
        quota_service.increment_success_service_use()
        return result
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode postal code polygon', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode postal code polygon')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_polygon(username text, orgname text, code double precision, country text)
RETURNS Geometry AS $$
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_polygon(username, orgname, code::text, country);
$$ LANGUAGE SQL STABLE PARALLEL RESTRICTED;

--------------------------------------------------------------------------------

-- Implementation of the server extension
-- Note: these functions depend on the cdb_geocoder extension
CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_geocode_postalcode_point(code text)
RETURNS Geometry AS $$
  DECLARE
    ret Geometry;
  BEGIN
    SELECT geom INTO ret
    FROM (
      SELECT
        q, (
          SELECT the_geom
          FROM global_postal_code_points
          WHERE postal_code = upper(d.q)
          LIMIT 1
        ) geom
      FROM (SELECT code q) d
    ) v;

    RETURN ret;
END
$$ LANGUAGE plpgsql STABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_geocode_postalcode_point(code text, country text)
RETURNS Geometry AS $$
  DECLARE
    ret Geometry;
  BEGIN
    SELECT geom INTO ret
    FROM (
      SELECT
        q, (
          SELECT the_geom
          FROM global_postal_code_points
          WHERE postal_code = upper(d.q)
            AND iso3 = (
                SELECT iso3 FROM country_decoder WHERE
                lower(country) = ANY (synonyms) LIMIT 1
            )
          LIMIT 1
        ) geom
      FROM (SELECT code q) d
    ) v;

    RETURN ret;
END
$$ LANGUAGE plpgsql STABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_geocode_postalcode_polygon(code text)
RETURNS Geometry AS $$
  DECLARE
    ret Geometry;
  BEGIN
    SELECT geom INTO ret
    FROM (
      SELECT
        q, (
          SELECT the_geom
          FROM global_postal_code_polygons
          WHERE postal_code = upper(d.q)
          LIMIT 1
        ) geom
      FROM (SELECT code q) d
    ) v;

    RETURN ret;
END
$$ LANGUAGE plpgsql STABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_geocode_postalcode_polygon(code text, country text)
RETURNS Geometry AS $$
  DECLARE
    ret Geometry;
  BEGIN
    SELECT geom INTO ret
    FROM (
      SELECT
        q, (
          SELECT the_geom
          FROM global_postal_code_polygons
          WHERE postal_code = upper(d.q)
            AND iso3 = (
                SELECT iso3 FROM country_decoder WHERE
                lower(country) = ANY (synonyms) LIMIT 1
            )
          LIMIT 1
        ) geom
      FROM (SELECT code q) d
    ) v;

    RETURN ret;
END
$$ LANGUAGE plpgsql STABLE PARALLEL SAFE;
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_ipaddress_point(username text, orgname text, ip text)
RETURNS Geometry AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.metrics import InternalGeocoderConfig
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)

  params = {'username': username, 'orgname': orgname, 'ip': ip}

  with metrics('cdb_geocode_ipaddress_point', user_geocoder_config, logger):
    try:
      plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_ipaddress_point(trim($1)) AS mypoint", ["TEXT"])
      rv = plpy.execute(plan, [ip], 1)
      result = rv[0]["mypoint"]
      if result:
        quota_service.increment_success_service_use()
        return result
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode postal code polygon', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode postal code polygon')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

--------------------------------------------------------------------------------

-- Implementation of the server extension
-- Note: these functions depend on the cdb_geocoder extension
CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_geocode_ipaddress_point(ip text)
RETURNS Geometry AS $$
    DECLARE
        ret Geometry;

        new_ip INET;
    BEGIN
    BEGIN
        IF family(ip::inet) = 6 THEN
            new_ip := ip::inet;
        ELSE
            new_ip := ('::ffff:' || ip)::inet;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        SELECT NULL as geom INTO ret;
        RETURN ret;
    END;

    WITH
        ips AS (SELECT ip s, new_ip net),
        matches AS (SELECT s, (SELECT the_geom FROM ip_address_locations WHERE network_start_ip <= ips.net ORDER BY network_start_ip DESC LIMIT 1) geom FROM ips)
    SELECT geom INTO ret
        FROM matches;
    RETURN ret;
END
$$ LANGUAGE plpgsql STABLE PARALLEL SAFE;
CREATE TYPE cdb_dataservices_server.isoline AS (center geometry(Geometry,4326), data_range integer, the_geom geometry(Multipolygon,4326));

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_here_routing_isolines(username TEXT, orgname TEXT, type TEXT, source geometry(Geometry, 4326), mode TEXT, data_range integer[], options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  import json
  from cartodb_services.here import HereMapsRoutingIsoline
  from cartodb_services.metrics import QuotaService
  from cartodb_services.here.types import geo_polyline_to_multipolygon
  from cartodb_services.tools import Logger,LoggerConfig

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_isolines_routing_config = GD["user_isolines_routing_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  # -- Check the quota
  quota_service = QuotaService(user_isolines_routing_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
    client = HereMapsRoutingIsoline(user_isolines_routing_config.heremaps_app_id,
      user_isolines_routing_config.heremaps_app_code, logger)

    if source:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
      source_str = 'geo!%f,%f' % (lat, lon)
    else:
      source_str = None

    if type == 'isodistance':
      resp = client.calculate_isodistance(source_str, mode, data_range, options)
    elif type == 'isochrone':
      resp = client.calculate_isochrone(source_str, mode, data_range, options)

    if resp:
      result = []
      for isoline in resp:
        data_range_n = isoline['range']
        polyline = isoline['geom']
        multipolygon = geo_polyline_to_multipolygon(polyline)
        result.append([source, data_range_n, multipolygon])
      quota_service.increment_success_service_use()
      quota_service.increment_isolines_service_use(len(resp))
      return result
    else:
      quota_service.increment_empty_service_use()
      return []
  except BaseException as e:
    import sys
    quota_service.increment_failed_service_use()
    logger.error('Error trying to get mapzen isolines', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to get mapzen isolines')
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_isodistance(
   username TEXT,
   orgname TEXT,
   source geometry(Geometry, 4326),
   mode TEXT,
   data_range integer[],
   options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  import json
  from cartodb_services.mapzen import MatrixClient, MapzenIsolines
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_isolines_routing_config = GD["user_isolines_routing_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_isolines_routing_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
    client = MatrixClient(user_isolines_routing_config.mapzen_matrix_api_key, logger, user_isolines_routing_config.mapzen_matrix_service_params)
    mapzen_isolines = MapzenIsolines(client, logger)

    if source:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
      origin = {'lat': lat, 'lon': lon}
    else:
      raise Exception('source is NULL')

    # -- TODO Support options properly
    isolines = {}
    for r in data_range:
        isoline = mapzen_isolines.calculate_isodistance(origin, mode, r)
        isolines[r] = isoline

    result = []
    for r in data_range:

      if len(isolines[r]) >= 3:
        # -- TODO encapsulate this block into a func/method
        locations = isolines[r] + [ isolines[r][0] ] # close the polygon repeating the first point
        wkt_coordinates = ','.join(["%f %f" % (l['lon'], l['lat']) for l in locations])
        sql = "SELECT ST_MPolyFromText('MULTIPOLYGON((({0})))', 4326) as geom".format(wkt_coordinates)
        multipolygon = plpy.execute(sql, 1)[0]['geom']
      else:
        multipolygon = None

      result.append([source, r, multipolygon])

    quota_service.increment_success_service_use()
    quota_service.increment_isolines_service_use(len(isolines))
    return result
  except BaseException as e:
    import sys
    quota_service.increment_failed_service_use()
    logger.error('Error trying to get mapzen isolines', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to get mapzen isolines')
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapbox_isodistance(
   username TEXT,
   orgname TEXT,
   source geometry(Geometry, 4326),
   mode TEXT,
   data_range integer[],
   options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  from cartodb_services.tools import ServiceManager
  from cartodb_services.mapbox import MapboxIsolines
  from cartodb_services.mapbox.types import TRANSPORT_MODE_TO_MAPBOX
  from cartodb_services.tools import Coordinate
  from cartodb_services.refactor.service.mapbox_isolines_config import MapboxIsolinesConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('isolines', MapboxIsolinesConfigBuilder, username, orgname, GD)
  service_manager.assert_within_limits()

  try:
    mapbox_isolines = MapboxIsolines(service_manager.config.mapbox_api_key, service_manager.logger, service_manager.config.service_params)

    if source:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
      origin = Coordinate(lon,lat)
    else:
      raise Exception('source is NULL')

    profile = TRANSPORT_MODE_TO_MAPBOX.get(mode)

    # -- TODO Support options properly
    isolines = {}
    for r in data_range:
        isoline = mapbox_isolines.calculate_isodistance(origin, r, profile)
        isolines[r] = isoline

    result = []
    for r in data_range:

      if len(isolines[r]) >= 3:
        # -- TODO encapsulate this block into a func/method
        locations = isolines[r] + [ isolines[r][0] ] # close the polygon repeating the first point
        wkt_coordinates = ','.join(["%f %f" % (l.longitude, l.latitude) for l in locations])
        sql = "SELECT ST_CollectionExtract(ST_MakeValid(ST_MPolyFromText('MULTIPOLYGON((({0})))', 4326)),3) as geom".format(wkt_coordinates)
        multipolygon = plpy.execute(sql, 1)[0]['geom']
      else:
        multipolygon = None

      result.append([source, r, multipolygon])

    service_manager.quota_service.increment_success_service_use()
    service_manager.quota_service.increment_isolines_service_use(len(isolines))
    return result
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to get Mapbox isolines', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to get Mapbox isolines')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_tomtom_isodistance(
   username TEXT,
   orgname TEXT,
   source geometry(Geometry, 4326),
   mode TEXT,
   data_range integer[],
   options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  from cartodb_services.tools import ServiceManager
  from cartodb_services.tomtom import TomTomIsolines
  from cartodb_services.tomtom.types import TRANSPORT_MODE_TO_TOMTOM
  from cartodb_services.tools import Coordinate
  from cartodb_services.refactor.service.tomtom_isolines_config import TomTomIsolinesConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('isolines', TomTomIsolinesConfigBuilder, username, orgname, GD)
  service_manager.assert_within_limits()

  try:
    tomtom_isolines = TomTomIsolines(service_manager.config.tomtom_api_key, service_manager.logger, service_manager.config.service_params)

    if source:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
      origin = Coordinate(lon,lat)
    else:
      raise Exception('source is NULL')

    profile = TRANSPORT_MODE_TO_TOMTOM.get(mode)

    # -- TODO Support options properly
    isolines = {}
    for r in data_range:
        isoline = tomtom_isolines.calculate_isodistance(origin, r, profile)
        isolines[r] = isoline

    result = []
    for r in data_range:

      if len(isolines[r]) >= 3:
        # -- TODO encapsulate this block into a func/method
        locations = isolines[r] + [ isolines[r][0] ] # close the polygon repeating the first point
        wkt_coordinates = ','.join(["%f %f" % (l.longitude, l.latitude) for l in locations])
        sql = "SELECT ST_CollectionExtract(ST_MakeValid(ST_MPolyFromText('MULTIPOLYGON((({0})))', 4326)),3) as geom".format(wkt_coordinates)
        multipolygon = plpy.execute(sql, 1)[0]['geom']
      else:
        multipolygon = None

      result.append([source, r, multipolygon])

    service_manager.quota_service.increment_success_service_use()
    service_manager.quota_service.increment_isolines_service_use(len(isolines))
    return result
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to get TomTom isolines', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to get TomTom isolines')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_isochrones(
   username TEXT,
   orgname TEXT,
   source geometry(Geometry, 4326),
   mode TEXT,
   data_range integer[],
   options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  import json
  from cartodb_services.mapzen import MatrixClient, MapzenIsochrones
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig
  from cartodb_services.mapzen.types import coordinates_to_polygon

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_isolines_routing_config = GD["user_isolines_routing_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  # -- Check the quota
  quota_service = QuotaService(user_isolines_routing_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
    mapzen_isochrones = MapzenIsochrones(user_isolines_routing_config.mapzen_matrix_api_key,
                                         logger, user_isolines_routing_config.mapzen_isochrones_service_params)

    if source:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
      origin = {'lat': lat, 'lon': lon}
    else:
      raise Exception('source is NULL')

    resp = mapzen_isochrones.isochrone(origin, mode, data_range)

    if resp:
      result = []
      for isochrone in resp:
        result_polygon = coordinates_to_polygon(isochrone.coordinates)
        if result_polygon:
          result.append([source, isochrone.duration, result_polygon])
        else:
          result.append([source, isochrone.duration, None])
      quota_service.increment_success_service_use()
      quota_service.increment_isolines_service_use(len(result))
      return result
    else:
      quota_service.increment_empty_service_use()
      return []
  except BaseException as e:
    import sys
    quota_service.increment_failed_service_use()
    logger.error('Error trying to get mapzen isochrones', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to get mapzen isochrones')
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapbox_isochrones(
   username TEXT,
   orgname TEXT,
   source geometry(Geometry, 4326),
   mode TEXT,
   data_range integer[],
   options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  from cartodb_services.tools import ServiceManager
  from cartodb_services.mapbox import MapboxIsolines
  from cartodb_services.mapbox.types import TRANSPORT_MODE_TO_MAPBOX
  from cartodb_services.tools import Coordinate
  from cartodb_services.tools.coordinates import coordinates_to_polygon
  from cartodb_services.refactor.service.mapbox_isolines_config import MapboxIsolinesConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('isolines', MapboxIsolinesConfigBuilder, username, orgname, GD)
  service_manager.assert_within_limits()

  try:
    mapbox_isolines = MapboxIsolines(service_manager.config.mapbox_api_key, service_manager.logger, service_manager.config.service_params)

    if source:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
      origin = Coordinate(lon,lat)
    else:
      raise Exception('source is NULL')

    profile = TRANSPORT_MODE_TO_MAPBOX.get(mode)

    resp = mapbox_isolines.calculate_isochrone(origin, data_range, profile)

    if resp:
      result = []
      for isochrone in resp:
        result_polygon = coordinates_to_polygon(isochrone.coordinates)
        if result_polygon:
          result.append([source, isochrone.duration, result_polygon])
        else:
          result.append([source, isochrone.duration, None])
      service_manager.quota_service.increment_success_service_use()
      service_manager.quota_service.increment_isolines_service_use(len(result))
      return result
    else:
      service_manager.quota_service.increment_empty_service_use()
      return []
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to get Mapbox isochrones', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to get Mapbox isochrones')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_tomtom_isochrones(
   username TEXT,
   orgname TEXT,
   source geometry(Geometry, 4326),
   mode TEXT,
   data_range integer[],
   options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  from cartodb_services.tools import ServiceManager
  from cartodb_services.tomtom import TomTomIsolines
  from cartodb_services.tomtom.types import TRANSPORT_MODE_TO_TOMTOM
  from cartodb_services.tools import Coordinate
  from cartodb_services.tools.coordinates import coordinates_to_polygon
  from cartodb_services.refactor.service.tomtom_isolines_config import TomTomIsolinesConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('isolines', TomTomIsolinesConfigBuilder, username, orgname, GD)
  service_manager.assert_within_limits()

  try:
    tomtom_isolines = TomTomIsolines(service_manager.config.tomtom_api_key, service_manager.logger, service_manager.config.service_params)

    if source:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
      origin = Coordinate(lon,lat)
    else:
      raise Exception('source is NULL')

    profile = TRANSPORT_MODE_TO_TOMTOM.get(mode)

    resp = tomtom_isolines.calculate_isochrone(origin, data_range, profile)

    if resp:
      result = []
      for isochrone in resp:
        result_polygon = coordinates_to_polygon(isochrone.coordinates)
        if result_polygon:
          result.append([source, isochrone.duration, result_polygon])
        else:
          result.append([source, isochrone.duration, None])
      service_manager.quota_service.increment_success_service_use()
      service_manager.quota_service.increment_isolines_service_use(len(result))
      return result
    else:
      service_manager.quota_service.increment_empty_service_use()
      return []
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to get TomTom isochrones', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to get TomTom isochrones')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_isodistance(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  params = {'username': username, 'orgname': orgname, 'source': source, 'mode': mode, 'range': range, 'options': options}

  with metrics('cdb_isodistance', user_isolines_config, logger, params):
    if user_isolines_config.heremaps_provider:
      here_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_here_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(here_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapzen_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapzen_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapbox_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapbox_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.tomtom_provider:
      tomtom_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_tomtom_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(tomtom_plan, [username, orgname, source, mode, range, options])
    else:
      raise Exception('Requested isolines provider is not available')
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

-- heremaps isodistance
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_here_isodistance(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
  type = 'isodistance'

  here_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_here_routing_isolines($1, $2, $3, $4, $5, $6, $7) as isoline; ", ["text", "text", "text", "geometry(Geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(here_plan, [username, orgname, type, source, mode, range, options])

  return result
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

-- mapzen isodistance
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapzen_isodistance(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]

  mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(mapzen_plan, [username, orgname, source, mode, range, options])

  return result
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

-- mapbox isodistance
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapbox_isodistance(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]

  mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapbox_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(mapbox_plan, [username, orgname, source, mode, range, options])

  return result
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

-- tomtom isodistance
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_tomtom_isodistance(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]

  tomtom_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_tomtom_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(tomtom_plan, [username, orgname, source, mode, range, options])

  return result
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_isochrone(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  params = {'username': username, 'orgname': orgname, 'source': source, 'mode': mode, 'range': range, 'options': options}

  with metrics('cdb_isochrone', user_isolines_config, logger, params):
    if user_isolines_config.heremaps_provider:
      here_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_here_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(here_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapzen_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapzen_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapbox_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapbox_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.tomtom_provider:
      tomtom_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_tomtom_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(tomtom_plan, [username, orgname, source, mode, range, options])
    else:
      raise Exception('Requested isolines provider is not available')
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

-- heremaps isochrone
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_here_isochrone(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
  type = 'isochrone'

  here_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_here_routing_isolines($1, $2, $3, $4, $5, $6, $7) as isoline; ", ["text", "text", "text", "geometry(Geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(here_plan, [username, orgname, type, source, mode, range, options])

  return result
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

-- mapzen isochrone
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapzen_isochrone(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]

  mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_isochrones($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(mapzen_plan, [username, orgname, source, mode, range, options])
  return result
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

-- mapbox isochrone
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapbox_isochrone(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]

  mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapbox_isochrones($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(mapbox_plan, [username, orgname, source, mode, range, options])
  return result
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

-- tomtom isochrone
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_tomtom_isochrone(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]

  tomtom_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_tomtom_isochrones($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(tomtom_plan, [username, orgname, source, mode, range, options])
  return result
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT *
        FROM   pg_catalog.pg_user
        WHERE  usename = 'geocoder_api') THEN

            CREATE USER geocoder_api;
    END IF;
    GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA cdb_dataservices_server TO geocoder_api;
    GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO geocoder_api;
    GRANT USAGE ON SCHEMA cdb_dataservices_server TO geocoder_api;
    GRANT USAGE ON SCHEMA public TO geocoder_api;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO geocoder_api;
END$$;
