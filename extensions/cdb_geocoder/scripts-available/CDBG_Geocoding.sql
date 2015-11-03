-- Check if a given host is up by performing a ping -c 1 call.
CREATE OR REPLACE FUNCTION CDBG_Geocode_Street_Address(searchtext TEXT, state TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
  RETURNS Geometry
AS $$
  from heremaps import heremapsgeocoder
  from secrets import *

  geocoder = heremapsgeocoder.Geocoder(app_id, app_code)

  response = geocoder.geocodeAddress(searchtext, state=state, country=country)
  coordinates = geocoder.extractLngLatFromResponse(response)

  plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
  point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]

  return point['st_setsrid']
  return None
$$ LANGUAGE plpythonu VOLATILE;
