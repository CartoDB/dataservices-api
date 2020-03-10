DROP FUNCTION IF EXISTS cdb_dataservices_server._get_redis_conf_v2(text);
DROP FUNCTION IF EXISTS cdb_dataservices_server._connect_to_redis(text);
DROP FUNCTION IF EXISTS cdb_dataservices_server._get_geocoder_config(text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_geocode_street_point(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_geocode_street_point_v2(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_here_geocode_street_point(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_google_geocode_street_point(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_street_point(searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
  RETURNS Geometry
AS $$
  import json
  from heremaps import heremapsgeocoder

  heremaps_conf = json.loads(plpy.execute("SELECT cdb_dataservices_server._get_conf('heremaps')", 1)[0]['get_conf'])

  app_id = heremaps_conf['geocoder']['app_id']
  app_code = heremaps_conf['geocoder']['app_code']

  geocoder = heremapsgeocoder.Geocoder(app_id, app_code)

  results = geocoder.geocode_address(searchtext=searchtext, city=city, state=state_province, country=country)
  coordinates = geocoder.extract_lng_lat_from_result(results[0])

  plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
  point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]

  return point['st_setsrid']
$$ LANGUAGE @@plpythonu@@;
