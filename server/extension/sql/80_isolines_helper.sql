CREATE TYPE cdb_dataservices_server.isoline AS (center geometry(Geometry,4326), data_range integer, the_geom geometry(Multipolygon,4326));

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_here_routing_isolines(username TEXT, orgname TEXT, type TEXT, source geometry(Geometry, 4326), mode TEXT, data_range integer[], options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  import json
  from cartodb_services.here import HereMapsRoutingIsoline
  from cartodb_services.metrics import QuotaService
  from cartodb_services.here.types import geo_polyline_to_multipolygon

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_isolines_routing_config = GD["user_isolines_routing_config_{0}".format(username)]

  # -- Check the quota
  quota_service = QuotaService(user_isolines_routing_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

  try:
    client = HereMapsRoutingIsoline(user_isolines_routing_config.heremaps_app_id, user_isolines_routing_config.heremaps_app_code, base_url = HereMapsRoutingIsoline.PRODUCTION_ROUTING_BASE_URL)

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
    import sys, traceback
    type_, value_, traceback_ = sys.exc_info()
    quota_service.increment_failed_service_use()
    error_msg = 'There was an error trying to obtain isodistances using here maps geocoder: {0}'.format(e)
    plpy.notice(traceback.format_tb(traceback_))
    plpy.error(error_msg)
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu SECURITY DEFINER;


CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_routing_isolines(
   username TEXT,
   orgname TEXT,
   isotype TEXT,
   source geometry(Geometry, 4326),
   mode TEXT,
   data_range integer[],
   options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  import json
  from cartodb_services.mapzen import MapzenIsolines
  from cartodb_services.metrics import QuotaService
  from cartodb_services.here.types import geo_polyline_to_multipolygon # TODO do we use the same types?

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_isolines_routing_config = GD["user_isolines_routing_config_{0}".format(username)]

  # -- Check the quota
  #quota_service = QuotaService(user_isolines_routing_config, redis_conn)
  #if not quota_service.check_user_quota():
  #  plpy.error('You have reached the limit of your quota')

  try:
    # TODO: encapsulate or refactor this ugly code
    mapzen_conf_str = plpy.execute("SELECT * FROM CDB_Conf_Getconf('mapzen_conf') AS mapzen_conf")[0]['mapzen_conf']
    mapzen_conf = json.loads(mapzen_conf_str)

    client = MapzenIsolines(mapzen_conf['routing']['api_key'])

    if source:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
      source_str = 'geo!%f,%f' % (lat, lon)
    else:
      source_str = None

    if isotype == 'isodistance':
      resp = client.calculate_isodistance(source_str, mode, data_range, options)
    elif isotype == 'isochrone':
      resp = client.calculate_isochrone(source_str, mode, data_range, options)

    if resp:
      result = []
      for isoline in resp:
        data_range_n = isoline['range']
        polyline = isoline['geom']
        multipolygon = geo_polyline_to_multipolygon(polyline)
        result.append([source, data_range_n, multipolygon])
      #quota_service.increment_success_service_use()
      #quota_service.increment_isolines_service_use(len(resp))
      return result
    else:
      #quota_service.increment_empty_service_use()
      return []
  except BaseException as e:
    import sys, traceback
    type_, value_, traceback_ = sys.exc_info()
    #quota_service.increment_failed_service_use()
    error_msg = 'There was an error trying to obtain isolines using mapzen: {0}'.format(e)
    #plpy.notice(traceback.format_tb(traceback_))
    raise e
    #plpy.error(error_msg)
  finally:
    pass
    #quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu SECURITY DEFINER;
