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
