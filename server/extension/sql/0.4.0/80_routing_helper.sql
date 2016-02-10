CREATE TYPE isoline AS (center geometry(Geometry,4326), range integer, the_geom geometry(Multipolygon,4326));

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_here_routing_isolines(username TEXT, orgname TEXT, type TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT NULL) 
RETURNS SETOF isoline AS $$
  import json
  from cartodb_services.here import HereMapsRoutingIsoline
  from cartodb_services.metrics import QuotaService

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_routing_config = GD["user_routing_config_{0}".format(username)]

  # -- Check the quota
  quota_service = QuotaService(user_routing_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reach the limit of your quota')

  try:
    client = HereMapsRoutingIsoline(user_routing_config.heremaps_app_id, user_routing_config.heremaps_app_code)

    #-- TODO: move this to a module function
    if source:
        lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
        lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
        start_str = 'geo!%f,%f' % (lat, lon)
    else:
        source_str = None

    if type == 'isodistance':
      resp = client.calculate_isodistance(source_str, mode, range, options)
    else if type == 'isochrone':
      resp = client.calculate_isochrone(source_str, mode, range, options)

    if resp:
      result = []

      for isoline in resp:
		range = isoline['range']
        polyline = isoline['geom']
        multipolygon = cdb.here.types.geo_polyline_to_multipolygon(polyline)
        result.append([source_str, mode, range, multipolygon])

      quota_service.increment_isolines_service_use(len(resp))
      return result
    else:
      quota_service.increment_empty_geocoder_use()

  except BaseException as e:
    import sys, traceback
    type_, value_, traceback_ = sys.exc_info()
    quota_service.increment_failed_geocoder_use()
    error_msg = 'There was an error trying to obtain isodistances using here maps geocoder: {0}'.format(e)
    plpy.notice(traceback.format_tb(traceback_))
    plpy.error(error_msg)

  finally:
      quota_service.increment_total_geocoder_use()
$$ LANGUAGE plpythonu SECURITY DEFINER;