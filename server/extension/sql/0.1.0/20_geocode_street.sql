-- Geocodes a street address given a searchtext and a state and/or country
CREATE OR REPLACE FUNCTION cdb_geocoder_server.cdb_geocode_street_point_v2(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  plpy.execute("SELECT cdb_geocoder_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_geocoder_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quota_nullable(orgname)))
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
