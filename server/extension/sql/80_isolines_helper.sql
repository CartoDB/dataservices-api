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
