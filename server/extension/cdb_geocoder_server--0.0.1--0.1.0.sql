-- Get the Redis configuration from the _conf table --
CREATE OR REPLACE FUNCTION cdb_geocoder_server._get_redis_conf_v2(config_key text)
RETURNS cdb_geocoder_server._redis_conf_params AS $$
    conf_query = "SELECT cartodb.CDB_Conf_GetConf('{0}') as conf".format(config_key)
    conf = plpy.execute(conf_query)[0]['conf']
    if conf is None:
      plpy.error("There is no redis configuration defined")
    else:
      import json
      params = json.loads(conf)
      return {
        "sentinel_host": params['sentinel_host'],
        "sentinel_port": params['sentinel_port'],
        "sentinel_master_id": params['sentinel_master_id'],
        "timeout": params['timeout'],
        "redis_db": params['redis_db']
      }
$$ LANGUAGE plpythonu;

-- Get the connection to redis from cache or create a new one
CREATE OR REPLACE FUNCTION cdb_geocoder_server._connect_to_redis(user_id text)
RETURNS boolean AS $$
  cache_key = "redis_connection_{0}".format(user_id)
  if cache_key in GD:
    return False
  else:
    from cartodb_geocoder import redis_helper
    metadata_config_params = plpy.execute("""select c.sentinel_host, c.sentinel_port,
        c.sentinel_master_id, c.timeout, c.redis_db
        from cdb_geocoder_server._get_redis_conf_v2('redis_metadata_config') c;""")[0]
    metrics_config_params = plpy.execute("""select c.sentinel_host, c.sentinel_port,
        c.sentinel_master_id, c.timeout, c.redis_db
        from cdb_geocoder_server._get_redis_conf_v2('redis_metrics_config') c;""")[0]
    redis_metadata_connection = redis_helper.RedisHelper(metadata_config_params['sentinel_host'],
        metadata_config_params['sentinel_port'],
        metadata_config_params['sentinel_master_id'],
        timeout=metadata_config_params['timeout'],
        redis_db=metadata_config_params['redis_db']).redis_connection()
    redis_metrics_connection = redis_helper.RedisHelper(metrics_config_params['sentinel_host'],
        metrics_config_params['sentinel_port'],
        metrics_config_params['sentinel_master_id'],
        timeout=metrics_config_params['timeout'],
        redis_db=metrics_config_params['redis_db']).redis_connection()
    GD[cache_key] = {
      'redis_metadata_connection': redis_metadata_connection,
      'redis_metrics_connection': redis_metrics_connection,
    }
    return True
$$ LANGUAGE plpythonu;

-- Get the Redis configuration from the _conf table --
CREATE OR REPLACE FUNCTION cdb_geocoder_server._get_geocoder_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_geocoder_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    import json
    from cartodb_geocoder import config_helper
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
    geocoder_config = config_helper.GeocoderConfig(redis_conn, username, orgname, heremaps_app_id, heremaps_app_code)
    # --Think about the security concerns with this kind of global cache, it should be only available
    # --for this user session but...
    GD[cache_key] = geocoder_config
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER;

-- Geocodes a street address given a searchtext and a state and/or country
CREATE OR REPLACE FUNCTION cdb_geocoder_server.cdb_geocode_street_point_v2(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  plpy.execute("SELECT cdb_geocoder_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_geocoder_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  if user_geocoder_config.heremaps_geocoder:
    here_plan = plpy.prepare("SELECT cdb_geocoder_server._cdb_here_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
    return plpy.execute(here_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
  elif user_geocoder_config.google_geocoder:
    google_plan = plpy.prepare("SELECT cdb_geocoder_server._cdb_google_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
    return plpy.execute(google_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
  else:
    plpy.error('Requested geocoder is not available')

$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_geocoder_server._cdb_here_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from heremaps import heremapsgeocoder
  from cartodb_geocoder import quota_service

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  # -- Check the quota
  quota_service = quota_service.QuotaService(user_geocoder_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reach the limit of your quota')

  try:
    geocoder = heremapsgeocoder.Geocoder(user_geocoder_config.heremaps_app_id, user_geocoder_config.heremaps_app_code)
    results = geocoder.geocode_address(searchtext=searchtext, city=city, state=state_province, country=country)
    coordinates = geocoder.extract_lng_lat_from_result(results[0])
    quota_service.increment_success_geocoder_use()
    plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
    point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]
    return point['st_setsrid']
  except heremapsgeocoder.EmptyGeocoderResponse:
    quota_service.increment_empty_geocoder_use()
    return None
  except BaseException as e:
    import sys, traceback
    type_, value_, traceback_ = sys.exc_info()
    quota_service.increment_failed_geocoder_use()
    error_msg = 'There was an error trying to geocode using here maps geocoder: {0}'.format(e)
    plpy.notice(traceback.format_tb(traceback_))
    plpy.error(error_msg)

$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_geocoder_server._cdb_google_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
    plpy.error('Google geocoder is not available yet')
    return None
$$ LANGUAGE plpythonu;

-- We apply again the grants to include the new functions
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA cdb_geocoder_server TO geocoder_api;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO geocoder_api;
GRANT USAGE ON SCHEMA cdb_geocoder_server TO geocoder_api;
GRANT USAGE ON SCHEMA public TO geocoder_api;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO geocoder_api;
