-- Geocodes a street address given a searchtext and a state and/or country
CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_address(searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
  RETURNS Geometry
AS $$
  import json

  -- TODO: grab c
  google = True

  provider = 'gme-geocoder' if google else 'hires-geocoder'

  config = json.loads(plpy.execute("SELECT cdb_geocoder_server._config_get('{}')".format(provider), 1)[0]['_config_get'])

  if not google:
    from heremaps import heremapsgeocoder

    app_id = config['app_id']
    app_code = config['app_code']

    geocoder = heremapsgeocoder.Geocoder(app_id, app_code)

    results = geocoder.geocode_address(searchtext=searchtext, city=city, state=state_province, country=country)
    coordinates = geocoder.extract_lng_lat_from_result(results[0])
  else:
    import googlemaps

    client_id = config['client_id']
    client_secret = config['client_secret']

    gmaps = googlemaps.Client(client_id=client_id, client_secret=client_secret)

    arg = lambda x: (', ' + x) if x else ''

    query = searchtext + arg(city) + arg(state_province) + arg(country)

    geocode_result = gmaps.geocode(query)

    lng = geocode_result[0]['geometry']['location']['lng']
    lat = geocode_result[0]['geometry']['location']['lat']

    coordinates = [lng, lat]
  end

    plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
    point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]

    return point['st_setsrid']
$$ LANGUAGE plpythonu;
