
CREATE OR REPLACE FUNCTION cdb_geocoder_server._get_geocoder_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_geocoder_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    import json
    from cartodb_services.metrics import GeocoderConfig
    plpy.execute("SELECT cdb_geocoder_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    heremaps_conf_json = plpy.execute("SELECT cartodb.CDB_Conf_GetConf('heremaps_conf') as heremaps_conf", 1)[0]['heremaps_conf']
    if not heremaps_conf_json:
      heremaps_app_id = None
      heremaps_app_code = None
    else:
      heremaps_conf = json.loads(heremaps_conf_json)
      heremaps_app_id = heremaps_conf['app_id']
      heremaps_app_code = heremaps_conf['app_code']
    geocoder_config = GeocoderConfig(redis_conn, username, orgname, heremaps_app_id, heremaps_app_code)
    # --Think about the security concerns with this kind of global cache, it should be only available
    # --for this user session but...
    GD[cache_key] = geocoder_config
    return True
$$ LANGUAGE plpythonu;

-- Get the connection to redis from cache or create a new one
CREATE OR REPLACE FUNCTION cdb_geocoder_server._connect_to_redis(user_id text)
RETURNS boolean AS $$
  cache_key = "redis_connection_{0}".format(user_id)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.tools import RedisConnection
    metadata_config_params = plpy.execute("""select c.sentinel_host, c.sentinel_port,
        c.sentinel_master_id, c.timeout, c.redis_db
        from cdb_geocoder_server._get_redis_conf_v2('redis_metadata_config') c;""")[0]
    metrics_config_params = plpy.execute("""select c.sentinel_host, c.sentinel_port,
        c.sentinel_master_id, c.timeout, c.redis_db
        from cdb_geocoder_server._get_redis_conf_v2('redis_metrics_config') c;""")[0]
    redis_metadata_connection = RedisConnection(metadata_config_params['sentinel_host'],
        metadata_config_params['sentinel_port'],
        metadata_config_params['sentinel_master_id'],
        timeout=metadata_config_params['timeout'],
        redis_db=metadata_config_params['redis_db']).redis_connection()
    redis_metrics_connection = RedisConnection(metrics_config_params['sentinel_host'],
        metrics_config_params['sentinel_port'],
        metrics_config_params['sentinel_master_id'],
        timeout=metrics_config_params['timeout'],
        redis_db=metrics_config_params['redis_db']).redis_connection()
    GD[cache_key] = {
      'redis_metadata_connection': redis_metadata_connection,
      'redis_metrics_connection': redis_metrics_connection,
    }
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_geocoder_server._cdb_here_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.here import HereMapsGeocoder
  from cartodb_services.metrics import QuotaService

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  # -- Check the quota
  quota_service = QuotaService(user_geocoder_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reach the limit of your quota')

  try:
    geocoder = HereMapsGeocoder(user_geocoder_config.heremaps_app_id, user_geocoder_config.heremaps_app_code)
    coordinates = geocoder.geocode(searchtext=searchtext, city=city, state=state_province, country=country)
    if coordinates:
      quota_service.increment_success_geocoder_use()
      plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
      point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]
      return point['st_setsrid']
    else:
      quota_service.increment_empty_geocoder_use()
      return None
  except BaseException as e:
    import sys, traceback
    type_, value_, traceback_ = sys.exc_info()
    quota_service.increment_failed_geocoder_use()
    error_msg = 'There was an error trying to geocode using here maps geocoder: {0}'.format(e)
    plpy.notice(traceback.format_tb(traceback_))
    plpy.error(error_msg)
  finally:
    quota_service.increment_total_geocoder_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_geocoder_server._cdb_google_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.google import GoogleMapsGeocoder
  from cartodb_services.metrics import QuotaService

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]
  quota_service = QuotaService(user_geocoder_config, redis_conn)

  try:
    geocoder = GoogleMapsGeocoder(user_geocoder_config.google_client_id, user_geocoder_config.google_api_key)
    coordinates = geocoder.geocode(searchtext=searchtext, city=city, state=state_province, country=country)
    if coordinates:
      quota_service.increment_success_geocoder_use()
      plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
      point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]
      return point['st_setsrid']
    else:
      quota_service.increment_empty_geocoder_use()
      return None
  except BaseException as e:
    import sys, traceback
    type_, value_, traceback_ = sys.exc_info()
    quota_service.increment_failed_geocoder_use()
    error_msg = 'There was an error trying to geocode using google maps geocoder: {0}'.format(e)
    plpy.notice(traceback.format_tb(traceback_))
    plpy.error(error_msg)
  finally:
    quota_service.increment_total_geocoder_use()
$$ LANGUAGE plpythonu;
