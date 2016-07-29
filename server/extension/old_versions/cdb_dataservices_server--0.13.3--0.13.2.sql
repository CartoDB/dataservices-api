--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.13.2'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_mapzen_geocoder_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_mapzen_geocoder_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import MapzenGeocoderConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    mapzen_geocoder_config = MapzenGeocoderConfig(redis_conn, plpy, username, orgname)
    GD[cache_key] = mapzen_geocoder_config
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_mapzen_isolines_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_mapzen_isolines_routing_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import MapzenIsolinesRoutingConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    mapzen_isolines_config = MapzenIsolinesRoutingConfig(redis_conn, plpy, username, orgname)
    GD[cache_key] = mapzen_isolines_config
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapzen_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  # The configuration is retrieved but no checks are performed on it
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_mapzen_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_mapzen_geocoder_config_{0}".format(username)]

  mapzen_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapzen_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
  return plpy.execute(mapzen_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']

$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.mapzen import MapzenGeocoder
  from cartodb_services.mapzen.types import country_to_iso3
  from cartodb_services.metrics import QuotaService

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_mapzen_geocoder_config = GD["user_mapzen_geocoder_config_{0}".format(username)]
  quota_service = QuotaService(user_mapzen_geocoder_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

  try:
    geocoder = MapzenGeocoder(user_mapzen_geocoder_config.mapzen_api_key)
    country_iso3 = None
    if country:
      country_iso3 = country_to_iso3(country)
    coordinates = geocoder.geocode(searchtext=searchtext, city=city,
                                   state_province=state_province,
                                   country=country_iso3)
    if coordinates:
      quota_service.increment_success_service_use()
      plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
      point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]
      return point['st_setsrid']
    else:
      quota_service.increment_empty_service_use()
      return None
  except BaseException as e:
    import sys, traceback
    type_, value_, traceback_ = sys.exc_info()
    quota_service.increment_failed_service_use()
    error_msg = 'There was an error trying to geocode using mapzen geocoder: {0}'.format(e)
    plpy.notice(traceback.format_tb(traceback_))
    plpy.error(error_msg)
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

-- isodistance

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_isodistance(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
  type = 'isodistance'

  if user_isolines_config.google_services_user:
    plpy.error('This service is not available for google service users.')

  here_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_here_routing_isolines($1, $2, $3, $4, $5, $6, $7) as isoline; ", ["text", "text", "text", "geometry(Geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(here_plan, [username, orgname, type, source, mode, range, options])

  return result
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapzen_isodistance(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_mapzen_isolines_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_mapzen_isolines_routing_config_{0}".format(username)]
  type = 'isodistance'

  mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_isolines($1, $2, $3, $4, $5, $6, $7) as isoline; ", ["text", "text", "text", "geometry(Geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(mapzen_plan, [username, orgname, type, source, mode, range, options])

  return result
$$ LANGUAGE plpythonu;

-- isochrones

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_isochrone(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
  type = 'isochrone'

  if user_isolines_config.google_services_user:
    plpy.error('This service is not available for google service users.')

  here_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_here_routing_isolines($1, $2, $3, $4, $5, $6, $7) as isoline; ", ["text", "text", "text", "geometry(Geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(here_plan, [username, orgname, type, source, mode, range, options])

  return result
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapzen_isochrone(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_mapzen_isolines_routing_config_{0}".format(username)]
  type = 'isochrone'

  mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_isolines($1, $2, $3, $4, $5, $6, $7) as isoline; ", ["text", "text", "text", "geometry(Geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(mapzen_plan, [username, orgname, type, source, mode, range, options])

  return result
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_isolines(
   username TEXT,
   orgname TEXT,
   isotype TEXT,
   source geometry(Geometry, 4326),
   mode TEXT,
   data_range integer[],
   options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  import json
  from cartodb_services.mapzen import MatrixClient
  from cartodb_services.mapzen import MapzenIsolines
  from cartodb_services.metrics import QuotaService

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_mapzen_isolines_routing_config = GD["user_mapzen_isolines_routing_config_{0}".format(username)]

  # -- Check the quota
  quota_service = QuotaService(user_mapzen_isolines_routing_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

  try:
    client = MatrixClient(user_mapzen_isolines_routing_config.mapzen_matrix_api_key)
    mapzen_isolines = MapzenIsolines(client)

    if source:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
      origin = {'lat': lat, 'lon': lon}
    else:
      raise Exception('source is NULL')

    # -- TODO Support options properly
    isolines = {}
    if isotype == 'isodistance':
      for r in data_range:
          isoline = mapzen_isolines.calculate_isodistance(origin, mode, r)
          isolines[r] = isoline
    elif isotype == 'isochrone':
      for r in data_range:
          isoline = mapzen_isolines.calculate_isochrone(origin, mode, r)
          isolines[r] = isoline

    result = []
    for r in data_range:

      if len(isolines[r]) >= 3:
        # -- TODO encapsulate this block into a func/method
        locations = isolines[r] + [ isolines[r][0] ] # close the polygon repeating the first point
        wkt_coordinates = ','.join(["%f %f" % (l['lon'], l['lat']) for l in locations])
        sql = "SELECT ST_MPolyFromText('MULTIPOLYGON((({0})))', 4326) as geom".format(wkt_coordinates)
        multipolygon = plpy.execute(sql, 1)[0]['geom']
      else:
        multipolygon = None

      result.append([source, r, multipolygon])

    quota_service.increment_success_service_use()
    quota_service.increment_isolines_service_use(len(isolines))
    return result
  except BaseException as e:
    import sys, traceback
    type_, value_, traceback_ = sys.exc_info()
    quota_service.increment_failed_service_use()
    error_msg = 'There was an error trying to obtain isolines using mapzen: {0}'.format(e)
    plpy.debug(traceback.format_tb(traceback_))
    raise e
    #plpy.error(error_msg)
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu SECURITY DEFINER;
