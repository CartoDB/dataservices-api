--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.12.0'" to load this file. \quit


CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_isolines(
   username TEXT,
   orgname TEXT,
   isotype TEXT,
   source geometry(Geometry, 4326),
   mode TEXT,
   data_range integer[],
   options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  import json
  from cartodb_services.mapzen import MatrixClient
  from cartodb_services.mapzen import MapzenIsolines
  from cartodb_services.metrics import QuotaService

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_mapzen_isolines_routing_config = GD["user_mapzen_isolines_routing_config_{0}".format(username)]

  # -- Check the quota
  quota_service = QuotaService(user_mapzen_isolines_routing_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

  try:
    client = MatrixClient(user_mapzen_isolines_routing_config.mapzen_matrix_api_key)
    mapzen_isolines = MapzenIsolines(client)

    if source:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
      origin = {'lat': lat, 'lon': lon}
    else:
      raise Exception('source is NULL')

    # -- TODO Support options properly
    isolines = {}
    if isotype == 'isodistance':
      for r in data_range:
          isoline = mapzen_isolines.calculate_isodistance(origin, mode, r)
          isolines[r] = (isoline)
    elif isotype == 'isochrone':
      for r in data_range:
          isoline = mapzen_isolines.calculate_isochrone(origin, mode, r)
          isolines[r] = (isoline)

    result = []
    for r in data_range:

      # -- TODO encapsulate this block into a func/method
      locations = isolines[r] + [ isolines[r][0] ] # close the polygon repeating the first point
      wkt_coordinates = ','.join(["%f %f" % (l['lon'], l['lat']) for l in locations])
      sql = "SELECT ST_MPolyFromText('MULTIPOLYGON((({0})))', 4326) as geom".format(wkt_coordinates)
      multipolygon = plpy.execute(sql, 1)[0]['geom']

      result.append([source, r, multipolygon])

    quota_service.increment_success_service_use()
    quota_service.increment_isolines_service_use(len(isolines))
    return result
  except BaseException as e:
    import sys, traceback
    type_, value_, traceback_ = sys.exc_info()
    quota_service.increment_failed_service_use()
    error_msg = 'There was an error trying to obtain isolines using mapzen: {0}'.format(e)
    plpy.debug(traceback.format_tb(traceback_))
    raise e
    #plpy.error(error_msg)
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu SECURITY DEFINER;