CREATE TYPE isoline AS (center geometry(Geometry,4326), range integer, the_geom geometry(Multipolygon,4326));

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
    heremaps_conf_json = plpy.execute("SELECT cartodb.CDB_Conf_GetConf('heremaps_conf') as heremaps_conf", 1)[0]['heremaps_conf']
    if not heremaps_conf_json:
      heremaps_app_id = None
      heremaps_app_code = None
    else:
      heremaps_conf = json.loads(heremaps_conf_json)
      heremaps_app_id = heremaps_conf['app_id']
      heremaps_app_code = heremaps_conf['app_code']
    routing_config = RoutingConfig(redis_conn, username, orgname, heremaps_app_id, heremaps_app_code)
    # --Think about the security concerns with this kind of global cache, it should be only available
    # --for this user session but...
    GD[cache_key] = routing_config
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER;

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

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_isodistance(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT NULL)
RETURNS Geometry AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_routing_config_{0}".format(username)]
  type = 'isodistance'

  if user_isolines_config.heremaps_geocoder:
    here_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_here_routing_isolines($1, $2, $3, $4, $5, $6, $7) as isoline; ", ["text", "text", "geometry(Geometry, 4326)", "text", "integer[]", "text[]"])
    return plpy.execute(here_plan, [username, orgname, type, source, mode, range, options], 1)
   else:
    plpy.error('Requested routing service is not available')

$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_isochrone(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT NULL)
RETURNS Geometry AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_routing_config_{0}".format(username)]
  type = 'isochrone'

  if user_isolines_config.heremaps_geocoder:
    here_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_here_routing_isolines($1, $2, $3, $4, $5, $6, $7) as isoline; ", ["text", "text", "text", "text", "geometry(Geometry, 4326)", "text", "integer[]", "text[]"])
    return plpy.execute(here_plan, [username, orgname, type, source, mode, range, options], 1)
   else:
    plpy.error('Requested routing service is not available')

$$ LANGUAGE plpythonu;
