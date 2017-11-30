--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.28.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION cdb_dataservices_server" to load this file. \quit
CREATE TYPE cdb_dataservices_server.simple_route AS (
    shape geometry(LineString,4326),
    length real,
    duration integer
);

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
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_routing_config = GD["user_routing_config_{0}".format(username)]
  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  with metrics('cdb_route_with_point', user_routing_config, logger):
    waypoints = [origin, destination]
    mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_route_with_waypoints($1, $2, $3, $4, $5, $6) as route;", ["text", "text", "geometry(Point, 4326)[]", "text", "text[]", "text"])
    result = plpy.execute(mapzen_plan, [username, orgname, waypoints, mode, options, units])
    return [result[0]['shape'],result[0]['length'], result[0]['duration']]
$$ LANGUAGE plpythonu;


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

  with metrics('cdb_route_with_waypoints', user_routing_config, logger):
    mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_route_with_waypoints($1, $2, $3, $4, $5, $6) as route;", ["text", "text", "geometry(Point, 4326)[]", "text", "text[]", "text"])
    result = plpy.execute(mapzen_plan, [username, orgname, waypoints, mode, options, units])
    return [result[0]['shape'],result[0]['length'], result[0]['duration']]
$$ LANGUAGE plpythonu;
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
$$ LANGUAGE plpythonu SECURITY DEFINER;
--
-- Observatory connection config
--
-- The purpose of this function is provide to the PL/Proxy functions
-- the connection string needed to connect with the current production database

CREATE OR REPLACE FUNCTION cdb_dataservices_server._obs_server_conn_str(
  username TEXT,
  orgname TEXT)
RETURNS text AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_snapshot_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_snapshot_config_{0}".format(username)]

  return user_obs_config.connection_str
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetDemographicSnapshotJSON(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL,
  geometry_level TEXT DEFAULT NULL)
RETURNS json AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetDemographicSnapshot(geom, time_span, geometry_level);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_get_demographic_snapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL,
  geometry_level TEXT DEFAULT NULL)
RETURNS json AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig
  import json

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_snapshot_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_snapshot_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getdemographicsnapshot', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetDemographicSnapshotJSON($1, $2, $3, $4, $5) as snapshot;", ["text", "text", "geometry(Geometry, 4326)", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, time_span, geometry_level])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['snapshot']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to obs_get_demographic_snapshot', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to obs_get_demographic_snapshot')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetDemographicSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL,
  geometry_level TEXT DEFAULT NULL)
RETURNS SETOF json AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetDemographicSnapshot(geom, time_span, geometry_level);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetDemographicSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL,
  geometry_level TEXT DEFAULT NULL)
RETURNS SETOF JSON AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_snapshot_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_snapshot_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getdemographicsnapshot', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetDemographicSnapshot($1, $2, $3, $4, $5) as snapshot;", ["text", "text", "geometry(Geometry, 4326)", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, time_span, geometry_level])
        if result:
          resp = []
          for element in result:
            value = element['snapshot']
            resp.append(value)
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to obs_get_demographic_snapshot', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to obs_get_demographic_snapshot')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetSegmentSnapshotJSON(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT NULL)
RETURNS json AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetSegmentSnapshot(geom, geometry_level);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_get_segment_snapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT NULL)
RETURNS json AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig
  import json

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_snapshot_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_snapshot_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getsegmentsnapshot', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetSegmentSnapshotJSON($1, $2, $3, $4) as snapshot;", ["text", "text", "geometry(Geometry, 4326)", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, geometry_level])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['snapshot']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to obs_get_segment_snapshot', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to obs_get_segment_snapshot')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetSegmentSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT NULL)
RETURNS SETOF json AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetSegmentSnapshot(geom, geometry_level);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetSegmentSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT NULL)
RETURNS SETOF JSON AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_snapshot_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_snapshot_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getsegmentsnapshot', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetSegmentSnapshot($1, $2, $3, $4) as snapshot;", ["text", "text", "geometry(Geometry, 4326)", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, geometry_level])
        if result:
          resp = []
          for element in result:
            value = element['snapshot']
            resp.append(value)
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetSegmentSnapshot', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetSegmentSnapshot')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetMeasure(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  measure_id TEXT,
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetMeasure(geom, measure_id, normalize, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetMeasure(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  measure_id TEXT,
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getmeasure', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetMeasure($1, $2, $3, $4, $5, $6, $7) as measure;", ["text", "text", "geometry(Geometry, 4326)", "text", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, measure_id, normalize, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['measure']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetMeasure', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetMeasure')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetCategory(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  category_id TEXT,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetCategory(geom, category_id, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetCategory(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  category_id TEXT,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getcategory', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetCategory($1, $2, $3, $4, $5, $6) as category;", ["text", "text", "geometry(Geometry, 4326)", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, category_id, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['category']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetCategory', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetCategory')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetUSCensusMeasure(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  name TEXT,
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetUSCensusMeasure(geom, name, normalize, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetUSCensusMeasure(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  name TEXT,
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getuscensusmeasure', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetUSCensusMeasure($1, $2, $3, $4, $5, $6, $7) as census_measure;", ["text", "text", "geometry(Geometry, 4326)", "text", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, name, normalize, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['census_measure']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetUSCensusMeasure', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetUSCensusMeasure')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetUSCensusCategory(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  name TEXT,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetUSCensusCategory(geom, name, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetUSCensusCategory(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  name TEXT,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getuscensuscategory', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetUSCensusCategory($1, $2, $3, $4, $5, $6) as census_category;", ["text", "text", "geometry(Geometry, 4326)", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, name, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['census_category']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetUSCensusCategory', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetUSCensusCategory')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetPopulation(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetPopulation(geom, normalize, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetPopulation(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getpopulation', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetPopulation($1, $2, $3, $4, $5, $6) as population;", ["text", "text", "geometry(Geometry, 4326)", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, normalize, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['population']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetPopulation', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetPopulation')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetMeasureById(
  username TEXT,
  orgname TEXT,
  geom_ref TEXT,
  measure_id TEXT,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetMeasureById(geom_ref, measure_id, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetMeasureById(
  username TEXT,
  orgname TEXT,
  geom_ref TEXT,
  measure_id TEXT,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getmeasurebyid', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetMeasureById($1, $2, $3, $4, $5, $6) as measure;", ["text", "text", "text", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom_ref, measure_id, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['measure']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetMeasureById', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetMeasureById')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetData(
  username TEXT,
  orgname TEXT,
  geomvals geomval[],
  params JSON,
  merge BOOLEAN DEFAULT True)
RETURNS TABLE (
  id INT,
  data JSON
) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetData(geomvals, params, merge);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetData(
  username TEXT,
  orgname TEXT,
  geomvals geomval[],
  params JSON,
  merge BOOLEAN DEFAULT True)
RETURNS TABLE (
  id INT,
  data JSON
) AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getdata', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetData($1, $2, $3, $4, $5);", ["text", "text", "geomval[]", "json", "boolean"])
        result = plpy.execute(obs_plan, [username, orgname, geomvals, params, merge])
        empty_results = len(geomvals) - len(result)
        if empty_results > 0:
          quota_service.increment_empty_service_use(empty_results)
        if result:
          quota_service.increment_success_service_use(len(result))
          return result
        else:
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use(len(geomvals))
        logger.error('Error trying to OBS_GetData', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetData')
    finally:
        quota_service.increment_total_service_use(len(geomvals))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetData(
  username TEXT,
  orgname TEXT,
  geomrefs TEXT[],
  params JSON)
RETURNS TABLE (
  id TEXT,
  data JSON
) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetData(geomrefs, params);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetData(
  username TEXT,
  orgname TEXT,
  geomrefs TEXT[],
  params JSON)
RETURNS TABLE (
  id TEXT,
  data JSON
) AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getdata', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetData($1, $2, $3, $4);", ["text", "text", "text[]", "json"])
        result = plpy.execute(obs_plan, [username, orgname, geomrefs, params])
        empty_results = len(geomrefs) - len(result)
        if empty_results > 0:
          quota_service.increment_empty_service_use(empty_results)
        if result:
          quota_service.increment_success_service_use(len(result))
          return result
        else:
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use(len(geomrefs))
        exc_info = sys.exc_info()
        logger.error('%s, %s, %s' % (exc_info[0], exc_info[1], exc_info[2]))
        logger.error('Error trying to OBS_GetData', exc_info, data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetData')
    finally:
        quota_service.increment_total_service_use(len(geomrefs))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetMeta(
  username TEXT,
  orgname TEXT,
  geom Geometry(Geometry, 4326),
  params JSON,
  max_timespan_rank INTEGER DEFAULT NULL,
  max_score_rank INTEGER DEFAULT NULL,
  target_geoms INTEGER DEFAULT NULL)
RETURNS JSON AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetMeta(geom, params, max_timespan_rank, max_score_rank, target_geoms);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetMeta(
  username TEXT,
  orgname TEXT,
  geom Geometry(Geometry, 4326),
  params JSON,
  max_timespan_rank INTEGER DEFAULT NULL,
  max_score_rank INTEGER DEFAULT NULL,
  target_geoms INTEGER DEFAULT NULL)
RETURNS JSON AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  with metrics('obs_getmeta', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetMeta($1, $2, $3, $4, $5, $6, $7) as meta;", ["text", "text", "Geometry (Geometry, 4326)", "json", "integer", "integer", "integer"])
        result = plpy.execute(obs_plan, [username, orgname, geom, params, max_timespan_rank, max_score_rank, target_geoms])
        if result:
          return result[0]['meta']
        else:
          return None
    except BaseException as e:
        import sys
        logger.error('Error trying to OBS_GetMeta', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetMeta')
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_MetadataValidation(
  username TEXT,
  orgname TEXT,
  geometry_extent Geometry(Geometry, 4326),
  geometry_type text,
  params JSON,
  target_geoms INTEGER DEFAULT NULL)
RETURNS TABLE(valid boolean, errors text[]) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_MetadataValidation(geometry_extent, geometry_type, params, target_geoms);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_MetadataValidation(
  username TEXT,
  orgname TEXT,
  geometry_extent Geometry(Geometry, 4326),
  geometry_type text,
  params JSON,
  target_geoms INTEGER DEFAULT NULL)
RETURNS TABLE(valid boolean, errors text[]) AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  with metrics('obs_metadatavalidation', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_MetadataValidation($1, $2, $3, $4, $5, $6);", ["text", "text", "Geometry (Geometry, 4326)",  "text", "json", "integer"])
        result = plpy.execute(obs_plan, [username, orgname, geometry_extent, geometry_type, params, target_geoms])
        if result:
          return result
        else:
          return []
    except BaseException as e:
        import sys
        logger.error('Error trying to OBS_MetadataValidation', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_MetadataValidation')
$$ LANGUAGE plpythonu;
CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_Search(
  username TEXT,
  orgname TEXT,
  search_term TEXT,
  relevant_boundary TEXT DEFAULT NULL)
RETURNS TABLE(id text, description text, name text, aggregate text, source text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_Search(search_term, relevant_boundary);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_Search(
  username TEXT,
  orgname TEXT,
  search_term TEXT,
  relevant_boundary TEXT DEFAULT NULL)
RETURNS TABLE(id text, description text, name text, aggregate text, source text) AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_search', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_Search($1, $2, $3, $4);", ["text", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, search_term, relevant_boundary])
        if result:
          resp = []
          for element in result:
            id = element['id']
            description = element['description']
            name = element['name']
            aggregate = element['aggregate']
            source = element['source']
            resp.append([id, description, name, aggregate, source])
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return [None, None, None, None, None]
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_Search', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_Search')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetAvailableBoundaries(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL)
RETURNS TABLE(boundary_id text, description text, time_span text, tablename text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableBoundaries(geom, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableBoundaries(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL)
RETURNS TABLE(boundary_id text, description text, time_span text, tablename text) AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getavailableboundaries', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetAvailableBoundaries($1, $2, $3, $4) as available_boundaries;", ["text", "text", "geometry(Geometry, 4326)", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, time_span])
        if result:
          resp = []
          for element in result:
            id = element['boundary_id']
            description = element['description']
            tspan = element['time_span']
            tablename = element['tablename']
            resp.append([id, description, tspan, tablename])
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetMeasureById', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetMeasureById')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;
CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetBoundary(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS geometry(Geometry, 4326) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetBoundary(geom, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundary(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS geometry(Geometry, 4326) AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getboundary', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetBoundary($1, $2, $3, $4) as boundary;", ["text", "text", "geometry(Point, 4326)", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['boundary']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetBoundary', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetBoundary')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetBoundaryId(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetBoundaryId(geom, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundaryId(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getboundaryid', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetBoundaryId($1, $2, $3, $4, $5) as boundary;", ["text", "text", "geometry(Point, 4326)", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['boundary']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetBoundaryId', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetBoundaryId')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetBoundaryById(
  username TEXT,
  orgname TEXT,
  geometry_id TEXT,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS geometry(Geometry, 4326) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetBoundaryById(geometry_id, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundaryById(
  username TEXT,
  orgname TEXT,
  geometry_id TEXT,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS geometry(Geometry, 4326) AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getboundarybyid', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetBoundaryById($1, $2, $3, $4, $5) as boundary;", ["text", "text", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geometry_id, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['boundary']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetBoundaryById', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetBoundaryById')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetBoundariesByGeometry(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetBoundariesByGeometry(geom, boundary_id, time_span, overlap_type);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundariesByGeometry(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getboundariesbygeometry', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetBoundariesByGeometry($1, $2, $3, $4, $5, $6) as boundary;", ["text", "text", "geometry(Point, 4326)", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, boundary_id, time_span, overlap_type])
        if result:
          resp = []
          for element in result:
            the_geom = element['the_geom']
            geom_refs = element['geom_refs']
            resp.append([the_geom, geom_refs])
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetBoundariesByGeometry', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetBoundariesByGeometry')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetBoundariesByPointAndRadius(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  radius NUMERIC,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetBoundariesByPointAndRadius(geom, radius, boundary_id, time_span, overlap_type);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundariesByPointAndRadius(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  radius NUMERIC,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getboundariesbypointandradius', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetBoundariesByPointAndRadius($1, $2, $3, $4, $5, $6, $7) as boundary;", ["text", "text", "geometry(Point, 4326)", "numeric", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, radius, boundary_id, time_span, overlap_type])
        if result:
          resp = []
          for element in result:
            the_geom = element['the_geom']
            geom_refs = element['geom_refs']
            resp.append([the_geom, geom_refs])
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetBoundariesByPointAndRadius', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetBoundariesByPointAndRadius')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetPointsByGeometry(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetPointsByGeometry(geom, boundary_id, time_span, overlap_type);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetPointsByGeometry(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getpointsbygeometry', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetPointsByGeometry($1, $2, $3, $4, $5, $6) as boundary;", ["text", "text", "geometry(Point, 4326)", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, boundary_id, time_span, overlap_type])
        if result:
          resp = []
          for element in result:
            the_geom = element['the_geom']
            geom_refs = element['geom_refs']
            resp.append([the_geom, geom_refs])
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetPointsByGeometry', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetPointsByGeometry')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetPointsByPointAndRadius(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  radius NUMERIC,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetPointsByPointAndRadius(geom, radius, boundary_id, time_span, overlap_type);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetPointsByPointAndRadius(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  radius NUMERIC,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getpointsbypointandradius', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetPointsByPointAndRadius($1, $2, $3, $4, $5, $6, $7) as boundary;", ["text", "text", "geometry(Point, 4326)", "numeric", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, radius, boundary_id, time_span, overlap_type])
        if result:
          resp = []
          for element in result:
            the_geom = element['the_geom']
            geom_refs = element['geom_refs']
            resp.append([the_geom, geom_refs])
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetPointsByPointAndRadius', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetPointsByPointAndRadius')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;
CREATE TYPE cdb_dataservices_server.ds_fdw_metadata as (schemaname text, tabname text, servername text);

CREATE TYPE cdb_dataservices_server.ds_return_metadata as (colnames text[], coltypes text[]);

CREATE OR REPLACE FUNCTION cdb_dataservices_server._DST_ConnectUserTable(username text, orgname text, user_db_role text, input_schema text, dbname text, table_name text)
RETURNS cdb_dataservices_server.ds_fdw_metadata AS $$
    host_addr = plpy.execute("SELECT split_part(inet_client_addr()::text, '/', 1) as user_host")[0]['user_host']
    return plpy.execute("SELECT * FROM cdb_dataservices_server.__DST_ConnectUserTable({username}::text, {orgname}::text, {user_db_role}::text, {schema}::text, {dbname}::text, {host_addr}::text, {table_name}::text)"
        .format(username=plpy.quote_nullable(username), orgname=plpy.quote_nullable(orgname), user_db_role=plpy.quote_literal(user_db_role), schema=plpy.quote_literal(input_schema), dbname=plpy.quote_literal(dbname), table_name=plpy.quote_literal(table_name), host_addr=plpy.quote_literal(host_addr))
        )[0]
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.__DST_ConnectUserTable(username text, orgname text, user_db_role text, input_schema text, dbname text, host_addr text, table_name text)
RETURNS cdb_dataservices_server.ds_fdw_metadata AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_ConnectUserTable;
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._DST_GetReturnMetadata(username text, orgname text, function_name text, params json)
RETURNS cdb_dataservices_server.ds_return_metadata AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_GetReturnMetadata;
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._DST_FetchJoinFdwTableData(username text, orgname text, table_schema text, table_name text, function_name text, params json)
RETURNS SETOF record AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_FetchJoinFdwTableData;
$$ LANGUAGE plproxy;


CREATE OR REPLACE FUNCTION cdb_dataservices_server._DST_DisconnectUserTable(username text, orgname text, table_schema text, table_name text, servername text)
RETURNS boolean AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_DisconnectUserTable;
$$ LANGUAGE plproxy;
CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_dumpversion(username text, orgname text)
RETURNS text AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.obs_dumpversion();
$$ LANGUAGE plproxy;

-- We could create a super type for the common data like id, name and so on but we need to parse inside the functions because the -- the return data tha comes from OBS is a TABLE() with them
CREATE TYPE cdb_dataservices_server.obs_meta_numerator AS (numer_id text, numer_name text, numer_description text, numer_weight text, numer_license text, numer_source text, numer_type text, numer_aggregate text, numer_extra jsonb, numer_tags jsonb, valid_denom boolean, valid_geom boolean, valid_timespan boolean);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableNumerators(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  filter_tags TEXT[] DEFAULT NULL,
  denom_id TEXT DEFAULT NULL,
  geom_id TEXT DEFAULT NULL,
  timespan TEXT DEFAULT NULL)
RETURNS SETOF cdb_dataservices_server.obs_meta_numerator AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableNumerators(bounds, filter_tags, denom_id, geom_id, timespan);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetNumerators(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  section_tags TEXT[] DEFAULT ARRAY[]::TEXT[],
  subsection_tags TEXT[] DEFAULT ARRAY[]::TEXT[],
  other_tags TEXT[] DEFAULT ARRAY[]::TEXT[],
  ids TEXT[] DEFAULT ARRAY[]::TEXT[],
  name TEXT DEFAULT NULL,
  denom_id TEXT DEFAULT '',
  geom_id TEXT DEFAULT '',
  timespan TEXT DEFAULT '')
RETURNS SETOF cdb_dataservices_server.obs_meta_numerator AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory._OBS_GetNumerators(bounds, section_tags, subsection_tags, other_tags, ids, name, denom_id, geom_id, timespan);
$$ LANGUAGE plproxy;

CREATE TYPE cdb_dataservices_server.obs_meta_denominator AS (denom_id text, denom_name text, denom_description text, denom_weight text, denom_license text, denom_source text, denom_type text, denom_aggregate text, denom_extra jsonb, denom_tags jsonb, valid_numer boolean, valid_geom boolean, valid_timespan boolean);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableDenominators(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  filter_tags TEXT[] DEFAULT NULL,
  numer_id TEXT DEFAULT NULL,
  geom_id TEXT DEFAULT NULL,
  timespan TEXT DEFAULT NULL)
RETURNS SETOF cdb_dataservices_server.obs_meta_denominator AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableDenominators(bounds, filter_tags, numer_id, geom_id, timespan);
$$ LANGUAGE plproxy;

CREATE TYPE cdb_dataservices_server.obs_meta_geometry AS (geom_id text, geom_name text, geom_description text, geom_weight text, geom_aggregate text, geom_license text, geom_source text, valid_numer boolean, valid_denom boolean, valid_timespan boolean, score numeric, numtiles bigint, notnull_percent numeric, numgeoms numeric, percentfill numeric, estnumgeoms numeric, meanmediansize numeric, geom_type text, geom_extra jsonb, geom_tags jsonb);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableGeometries(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  filter_tags TEXT[] DEFAULT NULL,
  numer_id TEXT DEFAULT NULL,
  denom_id TEXT DEFAULT NULL,
  timespan TEXT DEFAULT NULL,
  number_geometries INTEGER DEFAULT NULL)
RETURNS SETOF cdb_dataservices_server.obs_meta_geometry AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableGeometries(bounds, filter_tags, numer_id, denom_id, timespan, number_geometries);
$$ LANGUAGE plproxy;

CREATE TYPE cdb_dataservices_server.obs_meta_timespan AS (timespan_id text, timespan_name text, timespan_description text, timespan_weight text, timespan_aggregate text, timespan_license text, timespan_source text, valid_numer boolean, valid_denom boolean, valid_geom boolean, timespan_type text, timespan_extra jsonb, timespan_tags jsonb);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableTimespans(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  filter_tags TEXT[] DEFAULT NULL,
  numer_id TEXT DEFAULT NULL,
  denom_id TEXT DEFAULT NULL,
  geom_id TEXT DEFAULT NULL)
RETURNS SETOF cdb_dataservices_server.obs_meta_timespan AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableTimespans(bounds, filter_tags, numer_id, denom_id, geom_id);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_LegacyBuilderMetadata(
  username TEXT,
  orgname TEXT,
  aggregate_type TEXT DEFAULT NULL)
RETURNS TABLE(name TEXT, subsection JSON) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_LegacyBuilderMetadata(aggregate_type);
$$ LANGUAGE plproxy;
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
$$ LANGUAGE plpythonu SECURITY DEFINER;

-- This is done in order to avoid an undesired depedency on cartodb extension
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_conf_getconf(input_key text)
RETURNS JSON AS $$
    SELECT VALUE FROM cartodb.cdb_conf WHERE key = input_key;
$$ LANGUAGE SQL STABLE SECURITY DEFINER;

CREATE OR REPLACE
FUNCTION cdb_dataservices_server.CDB_Conf_SetConf(key text, value JSON)
    RETURNS void AS $$
BEGIN
    PERFORM cdb_dataservices_server.CDB_Conf_RemoveConf(key);
    EXECUTE 'INSERT INTO cartodb.CDB_CONF (KEY, VALUE) VALUES ($1, $2);' USING key, value;
END
$$ LANGUAGE PLPGSQL VOLATILE SECURITY DEFINER;

CREATE OR REPLACE
FUNCTION cdb_dataservices_server.CDB_Conf_RemoveConf(key text)
    RETURNS void AS $$
BEGIN
    EXECUTE 'DELETE FROM cartodb.CDB_CONF WHERE KEY = $1;' USING key;
END
$$ LANGUAGE PLPGSQL VOLATILE SECURITY DEFINER;


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
$$ LANGUAGE plpythonu SECURITY DEFINER;

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
$$ LANGUAGE plpythonu SECURITY DEFINER;

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
$$ LANGUAGE plpythonu SECURITY DEFINER;

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
$$ LANGUAGE plpythonu SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_obs_snapshot_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_obs_snapshot_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import ObservatorySnapshotConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    obs_snapshot_config = ObservatorySnapshotConfig(redis_conn, plpy, username, orgname)
    GD[cache_key] = obs_snapshot_config
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_obs_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_obs_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import ObservatoryConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    obs_config = ObservatoryConfig(redis_conn, plpy, username, orgname)
    GD[cache_key] = obs_config
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'service_type') THEN
    CREATE TYPE cdb_dataservices_server.service_type AS ENUM (
      'isolines',
      'hires_geocoder',
      'routing',
      'observatory'
    );
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'service_quota_info') THEN
    CREATE TYPE cdb_dataservices_server.service_quota_info AS (
      service cdb_dataservices_server.service_type,
      monthly_quota NUMERIC,
      used_quota NUMERIC,
      soft_limit BOOLEAN,
      provider TEXT
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

  #-- Observatory
  service = 'observatory'
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]
  user_service = UserMetricsService(user_obs_config, redis_conn)

  monthly_quota = user_obs_config.monthly_quota
  used_quota = user_service.used_quota(user_obs_config.service_type, today)
  soft_limit = user_obs_config.soft_limit
  provider = user_obs_config.provider
  ret += [[service, monthly_quota, used_quota, soft_limit, provider]]

  return ret
$$ LANGUAGE plpythonu;


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
$$ LANGUAGE plpgsql;
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

  with metrics('cdb_geocode_street_point', user_geocoder_config, logger):
    if user_geocoder_config.heremaps_geocoder:
      here_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_here_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
      return plpy.execute(here_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
    elif user_geocoder_config.google_geocoder:
      google_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_google_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
      return plpy.execute(google_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
    elif user_geocoder_config.mapzen_geocoder:
      mapzen_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapzen_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
      return plpy.execute(mapzen_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
    else:
      raise Exception('Requested geocoder is not available')

$$ LANGUAGE plpythonu;


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

$$ LANGUAGE plpythonu;

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

$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapzen_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  # The configuration is retrieved but no checks are performed on it
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  mapzen_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapzen_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
  return plpy.execute(mapzen_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']

$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_here_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.tools import LegacyServiceManager
  from cartodb_services.here import HereMapsGeocoder

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  service_manager = LegacyServiceManager('geocoder', username, orgname, GD)
  service_manager.assert_within_limits()

  try:
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
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to geocode street point using here maps', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using here maps')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_google_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.tools import LegacyServiceManager
  from cartodb_services.google import GoogleMapsGeocoder

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  service_manager = LegacyServiceManager('geocoder', username, orgname, GD)
  service_manager.assert_within_limits(quota=False)

  try:
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
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to geocode street point using google maps', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using google maps')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.tools import ServiceManager
  from cartodb_services.mapzen import MapzenGeocoder
  from cartodb_services.mapzen.types import country_to_iso3
  from cartodb_services.refactor.service.mapzen_geocoder_config import MapzenGeocoderConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('geocoder', MapzenGeocoderConfigBuilder, username, orgname)
  service_manager.assert_within_limits()

  try:
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
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to geocode street point using mapzen', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using mapzen')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

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
$$ LANGUAGE plpythonu;

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
$$ LANGUAGE plpythonu;

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
$$ LANGUAGE plpythonu;

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
$$ LANGUAGE plpythonu;
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
  with metrics('cdb_geocode_admin0_polygon', user_geocoder_config, logger):
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
$$ LANGUAGE plpythonu;


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
$$ LANGUAGE plpgsql;
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

  with metrics('cdb_geocode_admin1_polygon', user_geocoder_config, logger):
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
$$ LANGUAGE plpythonu;

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
$$ LANGUAGE plpythonu;

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
$$ LANGUAGE plpgsql;

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
$$ LANGUAGE plpgsql;

---- cdb_geocode_namedplace_point(city_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text)
RETURNS Geometry AS $$
  import spiexceptions
  try:
    mapzen_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapzen_geocode_namedplace($1, $2, $3) as point;", ["text", "text", "text"])
    return plpy.execute(mapzen_plan, [username, orgname, city_name])[0]['point']
  except spiexceptions.ExternalRoutineException as e:
    internal_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_internal_geocode_namedplace($1, $2, $3) as point;", ["text", "text", "text"])
    return plpy.execute(internal_plan, [username, orgname, city_name])[0]['point']
$$ LANGUAGE plpythonu;

---- cdb_geocode_namedplace_point(city_name text, country_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text, country_name text)
RETURNS Geometry AS $$
  import spiexceptions
  try:
    mapzen_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapzen_geocode_namedplace($1, $2, $3, NULL, $4) as point;", ["text", "text", "text", "text"])
    return plpy.execute(mapzen_plan, [username, orgname, city_name, country_name])[0]['point']
  except spiexceptions.ExternalRoutineException as e:
    internal_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_internal_geocode_namedplace($1, $2, $3, NULL, $4) as point;", ["text", "text", "text", "text"])
    return plpy.execute(internal_plan, [username, orgname, city_name, country_name])[0]['point']
$$ LANGUAGE plpythonu;

---- cdb_geocode_namedplace_point(city_name text, admin1_name text, country_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text, admin1_name text, country_name text)
RETURNS Geometry AS $$
  import spiexceptions
  try:
    mapzen_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapzen_geocode_namedplace($1, $2, $3, $4, $5) as point;", ["text", "text", "text", "text", "text"])
    return plpy.execute(mapzen_plan, [username, orgname, city_name, admin1_name, country_name])[0]['point']
  except spiexceptions.ExternalRoutineException as e:
    internal_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_internal_geocode_namedplace($1, $2, $3, $4, $5) as point;", ["text", "text", "text", "text", "text"])
    return plpy.execute(internal_plan, [username, orgname, city_name, admin1_name, country_name])[0]['point']
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_geocode_namedplace(username text, orgname text, city_name text, admin1_name text DEFAULT NULL, country_name text DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.mapzen import MapzenGeocoder
  from cartodb_services.mapzen.types import country_to_iso3
  from cartodb_services.metrics import QuotaService, metrics
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1}, {2})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname), plpy.quote_nullable('mapzen')))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('cdb_geocode_namedplace_point', user_geocoder_config, logger):
    try:
      geocoder = MapzenGeocoder(user_geocoder_config.mapzen_api_key, logger)
      country_iso3 = None
      if country_name:
        country_iso3 = country_to_iso3(country_name)
      coordinates = geocoder.geocode(searchtext=city_name, city=None,
                                    state_province=admin1_name,
                                    country=country_iso3, search_type='locality')
      if coordinates:
        quota_service.increment_success_service_use()
        plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
        point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]
        return point['st_setsrid']
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode city point using mapzen', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode city point using mapzen')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

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

  with metrics('cdb_geocode_namedplace_point', user_geocoder_config, logger):
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
$$ LANGUAGE plpythonu;

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
$$ LANGUAGE plpgsql;

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
$$ LANGUAGE plpgsql;

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
$$ LANGUAGE plpgsql;

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
  with metrics('cdb_geocode_postalcode_point', user_geocoder_config, logger):
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
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_point(username text, orgname text, code double precision)
RETURNS Geometry AS $$
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_point(username, orgname, code::text);
$$ LANGUAGE SQL;


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
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_point(username text, orgname text, code double precision, country text)
RETURNS Geometry AS $$
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_point(username, orgname, code::text, country);
$$ LANGUAGE SQL;


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
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_polygon(username text, orgname text, code double precision)
RETURNS Geometry AS $$
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_polygon(username, orgname, code::text)
$$ LANGUAGE SQL;



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
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_polygon(username text, orgname text, code double precision, country text)
RETURNS Geometry AS $$
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_polygon(username, orgname, code::text, country);
$$ LANGUAGE SQL;

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
$$ LANGUAGE plpgsql;

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
$$ LANGUAGE plpgsql;

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
$$ LANGUAGE plpgsql;

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
$$ LANGUAGE plpgsql;
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
$$ LANGUAGE plpythonu;

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
$$ LANGUAGE plpgsql;
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
$$ LANGUAGE plpythonu SECURITY DEFINER;

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
$$ LANGUAGE plpythonu SECURITY DEFINER;


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
          quota_service.increment_success_service_use()
          result.append([source, isochrone.duration, result_polygon])
        else:
          quota_service.increment_empty_service_use()
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
$$ LANGUAGE plpythonu SECURITY DEFINER;
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

  if user_isolines_config.google_services_user:
    raise Exception('This service is not available for google service users.')

  with metrics('cb_isodistance', user_isolines_config, logger):
    if user_isolines_config.heremaps_provider:
      here_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_here_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(here_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapzen_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapzen_plan, [username, orgname, source, mode, range, options])
    else:
      raise Exception('Requested isolines provider is not available')
$$ LANGUAGE plpythonu;

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
$$ LANGUAGE plpythonu;

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
$$ LANGUAGE plpythonu;
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

  if user_isolines_config.google_services_user:
    raise Exception('This service is not available for google service users.')

  with metrics('cb_isochrone', user_isolines_config, logger):
    if user_isolines_config.heremaps_provider:
      here_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_here_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(here_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapzen_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapzen_plan, [username, orgname, source, mode, range, options])
    else:
      raise Exception('Requested isolines provider is not available')
$$ LANGUAGE plpythonu;

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
$$ LANGUAGE plpythonu;

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
$$ LANGUAGE plpythonu;
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
