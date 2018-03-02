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
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;


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
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;
