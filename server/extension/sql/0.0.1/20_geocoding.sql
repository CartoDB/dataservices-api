-- Check if a given host is up by performing a ping -c 1 call.
CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_street(searchtext TEXT, state TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
  RETURNS Geometry
AS $$
  from heremaps import heremapsgeocoder

  geocoder = heremapsgeocoder.Geocoder(app_id, app_code)

  results = geocoder.geocode_address(searchtext=searchtext, state=state, country=country)
  coordinates = geocoder.extract_lng_lat_from_result(results[0])

  plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
  point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]

  return point['st_setsrid']
$$ LANGUAGE plpythonu VOLATILE;
