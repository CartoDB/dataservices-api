-- Geocodes a street address given a searchtext and a state and/or country
CREATE OR REPLACE FUNCTION geocode_street(searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
  RETURNS Geometry
AS $$
  from heremaps import heremapsgeocoder

  geocoder = heremapsgeocoder.Geocoder(app_id, app_code)

  results = geocoder.geocode_address(searchtext=searchtext, city=city, state=state_province, country=country)
  coordinates = geocoder.extract_lng_lat_from_result(results[0])

  plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
  point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]

  return point['st_setsrid']
$$ LANGUAGE plpythonu VOLATILE;
