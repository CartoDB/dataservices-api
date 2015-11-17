-- Geocodes a street address given a searchtext and a state and/or country
CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_address_point(user_config JSON, geocoder_config JSON, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
  RETURNS Geometry
AS $$
  import json
  from cartodb_geocoder import confighelper
  from geocoderfactory import geocoderfactory

  # TODO: Check quota

  geocoder_config_json = json.loads(geocoder_config)
  auth_dict = confighelper.GeocoderAuth(geocoder_config_json).get_auth_dict()

  geocoder = geocoderfactory.Factory(auth_dict['identifier'], auth_dict['secret']).factory(auth_dict['provider'])
  result = geocoder.geocode_address(searchtext=searchtext, city=city, state_province=state_province, country=country)[0]
  coordinates = geocoder.extract_lng_lat_from_result(result)

  plan = plpy.prepare("SELECT * FROM ST_SetSRID(ST_MakePoint($1, $2), 4326) the_geom", ["double precision", "double precision"])
  point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]

  return point['the_geom']
$$ LANGUAGE plpythonu;
