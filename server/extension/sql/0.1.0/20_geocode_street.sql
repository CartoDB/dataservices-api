-- Geocodes a street address given a searchtext and a state and/or country
DROP FUNCTION IF EXISTS cdb_geocoder_server.cdb_geocode_street_point(TEXT, TEXT, TEXT, TEXT);
CREATE OR REPLACE FUNCTION cdb_geocoder_server.cdb_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from heremaps import heremapsgeocoder
  from cartodb_geocoder import quota_service

  plpy.execute("SELECT cdb_geocoder_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_geocoder_server._get_geocoder_config('{0}', '{1}')".format(username, orgname))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  # -- Check the quota
  quota_service = quota_service.QuotaService(user_geocoder_config, redis_conn, username, orgname)
  if not quota_service.check_user_quota():
    plpy.error('You have reach the limit of your quota')

  geocoder = heremapsgeocoder.Geocoder(user_geocoder_config.heremaps_app_id, user_geocoder_config.heremaps_app_code)
  results = geocoder.geocode_address(searchtext=searchtext, city=city, state=state_province, country=country)
  coordinates = geocoder.extract_lng_lat_from_result(results[0])
  plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
  point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]

  return point['st_setsrid']
$$ LANGUAGE plpythonu;
