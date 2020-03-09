--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.34.2'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_mapbox_route_with_waypoints(text, text, geometry(Point, 4326)[], text, text[], text);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_tomtom_route_with_waypoints(text, text, geometry(Point, 4326)[], text, text[], text);
CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapbox_route_with_waypoints(
  username TEXT,
  orgname TEXT,
  waypoints geometry(Point, 4326)[],
  mode TEXT)
RETURNS cdb_dataservices_server.simple_route AS $$
  from cartodb_services.tools import ServiceManager
  from cartodb_services.mapbox import MapboxRouting
  from cartodb_services.mapbox.types import TRANSPORT_MODE_TO_MAPBOX
  from cartodb_services.tools import Coordinate
  from cartodb_services.tools.polyline import polyline_to_linestring
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
    raise Exception('Error trying to calculate Mapbox routing')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_tomtom_route_with_waypoints(
  username TEXT,
  orgname TEXT,
  waypoints geometry(Point, 4326)[],
  mode TEXT)
RETURNS cdb_dataservices_server.simple_route AS $$
  from cartodb_services.tools import ServiceManager
  from cartodb_services.tomtom import TomTomRouting
  from cartodb_services.tomtom.types import TRANSPORT_MODE_TO_TOMTOM
  from cartodb_services.tools import Coordinate
  from cartodb_services.tools.polyline import polyline_to_linestring
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
    service_manager.logger.error('Error trying to calculate TomTom routing', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to calculate TomTom routing')
  finally:
    service_manager.quota_service.increment_total_service_use()
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
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(mapzen_plan, [username, orgname, waypoints, mode])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    elif user_routing_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapbox_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(mapbox_plan, [username, orgname, waypoints, mode])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    elif user_routing_config.tomtom_provider:
      tomtom_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_tomtom_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(tomtom_plan, [username, orgname, waypoints, mode])
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
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(mapzen_plan, [username, orgname, waypoints, mode])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    elif user_routing_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapbox_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(mapbox_plan, [username, orgname, waypoints, mode])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    elif user_routing_config.tomtom_provider:
      tomtom_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_tomtom_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(tomtom_plan, [username, orgname, waypoints, mode])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    else:
      raise Exception('Requested routing method is not available')
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;
