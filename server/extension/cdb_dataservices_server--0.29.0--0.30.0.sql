--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.30.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapbox_route_with_waypoints(
  username TEXT,
  orgname TEXT,
  waypoints geometry(Point, 4326)[],
  mode TEXT)
RETURNS cdb_dataservices_server.simple_route AS $$
  import json
  from cartodb_services.mapbox import MapboxRouting, MapboxRoutingResponse
  from cartodb_services.mapbox.types import TRANSPORT_MODE_TO_MAPBOX
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Coordinate
  from cartodb_services.tools import Logger,LoggerConfig
  from cartodb_services.tools.polyline import polyline_to_linestring

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_routing_config = GD["user_routing_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  quota_service = QuotaService(user_routing_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
    client = MapboxRouting(user_routing_config.mapbox_api_key, logger, user_routing_config.mapbox_service_params)

    if not waypoints or len(waypoints) < 2:
      logger.info("Empty origin or destination")
      quota_service.increment_empty_service_use()
      return [None, None, None]

    if len(waypoints) > 25:
      logger.info("Too many waypoints (max 25)")
      quota_service.increment_empty_service_use()
      return [None, None, None]

    waypoint_coords = []
    for waypoint in waypoints:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % waypoint)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % waypoint)[0]['lon']
      waypoint_coords.append(Coordinate(lon,lat))

    profile = TRANSPORT_MODE_TO_MAPBOX.get(mode)

    resp = client.directions(waypoint_coords, profile)
    if resp and resp.shape:
      shape_linestring = polyline_to_linestring(resp.shape)
      if shape_linestring:
        quota_service.increment_success_service_use()
        return [shape_linestring, resp.length, int(round(resp.duration))]
      else:
        quota_service.increment_empty_service_use()
        return [None, None, None]
    else:
      quota_service.increment_empty_service_use()
      return [None, None, None]
  except BaseException as e:
    import sys
    quota_service.increment_failed_service_use()
    logger.error('Error trying to calculate Mapbox routing', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to calculate Mapbox routing')
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_route_point_to_point(
  username TEXT,
  orgname TEXT,
  origin geometry(Point, 4326),
  destination geometry(Point, 4326),
  mode TEXT,
  options text[] DEFAULT ARRAY[]::text[],
  units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_server.simple_route AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_routing_config = GD["user_routing_config_{0}".format(username)]
  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  with metrics('cdb_route_with_point', user_routing_config, logger):
    waypoints = [origin, destination]

    if user_routing_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(mapzen_plan, [username, orgname, waypoints, mode])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    elif user_routing_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapbox_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(mapbox_plan, [username, orgname, waypoints, mode])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    else:
      raise Exception('Requested routing method is not available')
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_route_with_waypoints(
  username TEXT,
  orgname TEXT,
  waypoints geometry(Point, 4326)[],
  mode TEXT,
  options text[] DEFAULT ARRAY[]::text[],
  units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_server.simple_route AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_routing_config = GD["user_routing_config_{0}".format(username)]
  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  with metrics('cdb_route_with_waypoints', user_routing_config, logger):
    if user_routing_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(mapzen_plan, [username, orgname, waypoints, mode])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    elif user_routing_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapbox_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(mapbox_plan, [username, orgname, waypoints, mode])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    else:
      raise Exception('Requested routing method is not available')
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger,LoggerConfig
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]
  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  with metrics('cdb_geocode_street_point', user_geocoder_config, logger):
    if user_geocoder_config.heremaps_geocoder:
      here_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_here_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
      return plpy.execute(here_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
    elif user_geocoder_config.google_geocoder:
      google_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_google_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
      return plpy.execute(google_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
    elif user_geocoder_config.mapzen_geocoder:
      mapzen_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapzen_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
      return plpy.execute(mapzen_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
    elif user_geocoder_config.mapbox_geocoder:
      mapbox_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapbox_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
      return plpy.execute(mapbox_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
    else:
      raise Exception('Requested geocoder is not available')

$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapbox_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  # The configuration is retrieved but no checks are performed on it
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  mapzen_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapbox_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
  return plpy.execute(mapzen_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']

$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.tools import ServiceManager
  from cartodb_services.mapzen import MapzenGeocoder
  from cartodb_services.tools.country import country_to_iso3
  from cartodb_services.refactor.service.mapzen_geocoder_config import MapzenGeocoderConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('geocoder', MapzenGeocoderConfigBuilder, username, orgname)
  service_manager.assert_within_limits()

  try:
    geocoder = MapzenGeocoder(service_manager.config.mapzen_api_key, service_manager.logger, service_manager.config.service_params)
    country_iso3 = None
    if country:
      country_iso3 = country_to_iso3(country)
    coordinates = geocoder.geocode(searchtext=searchtext, city=city,
                                   state_province=state_province,
                                   country=country_iso3, search_type='address')
    if coordinates:
      service_manager.quota_service.increment_success_service_use()
      plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
      point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]
      return point['st_setsrid']
    else:
      service_manager.quota_service.increment_empty_service_use()
      return None
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to geocode street point using mapzen', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using mapzen')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapbox_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.mapbox import MapboxGeocoder
  from cartodb_services.metrics import QuotaService, metrics
  from cartodb_services.tools import Logger,LoggerConfig
  from cartodb_services.tools.country import country_to_iso3

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1}, {2})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname), plpy.quote_nullable('mapbox')))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('cdb_mapbox_geocode_street_point', user_geocoder_config, logger):
    try:
      geocoder = MapboxGeocoder(user_geocoder_config.mapbox_api_key, logger, user_geocoder_config.mapbox_service_params)

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
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode street point using mapbox', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode street point using mapbox')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

---- cdb_geocode_namedplace_point(city_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text)
RETURNS Geometry AS $$
  import spiexceptions
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  try:
    street_point = plpy.prepare("SELECT cdb_dataservices_server.cdb_geocode_street_point($1, $2, $3) as point;", ["text", "text", "text"])
    return plpy.execute(street_point, [username, orgname, city_name])[0]['point']
  except spiexceptions.ExternalRoutineException as e:
    import sys
    logger.error('Error geocoding namedplace using geocode street point, falling back to internal geocoder', sys.exc_info(), data={"username": username, "orgname": orgname})
    internal_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_internal_geocode_namedplace($1, $2, $3) as point;", ["text", "text", "text"])
    return plpy.execute(internal_plan, [username, orgname, city_name])[0]['point']
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

---- cdb_geocode_namedplace_point(city_name text, country_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text, country_name text)
RETURNS Geometry AS $$
  import spiexceptions
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  try:
    street_point = plpy.prepare("SELECT cdb_dataservices_server.cdb_geocode_street_point($1, $2, $3, NULL, NULL, $4) as point;", ["text", "text", "text", "text"])
    return plpy.execute(street_point, [username, orgname, city_name, country_name])[0]['point']
  except spiexceptions.ExternalRoutineException as e:
    import sys
    logger.error('Error geocoding namedplace using geocode street point, falling back to internal geocoder', sys.exc_info(), data={"username": username, "orgname": orgname})
    internal_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_internal_geocode_namedplace($1, $2, $3, NULL, $4) as point;", ["text", "text", "text", "text"])
    return plpy.execute(internal_plan, [username, orgname, city_name, country_name])[0]['point']
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

---- cdb_geocode_namedplace_point(city_name text, admin1_name text, country_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text, admin1_name text, country_name text)
RETURNS Geometry AS $$
  import spiexceptions
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  try:
    street_point = plpy.prepare("SELECT cdb_dataservices_server.cdb_geocode_street_point($1, $2, $3, NULL, $4, $5) as point;", ["text", "text", "text", "text", "text"])
    return plpy.execute(street_point, [username, orgname, city_name, admin1_name, country_name])[0]['point']
  except spiexceptions.ExternalRoutineException as e:
    import sys
    logger.error('Error geocoding namedplace using geocode street point, falling back to internal geocoder', sys.exc_info(), data={"username": username, "orgname": orgname})
    internal_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_internal_geocode_namedplace($1, $2, $3, $4, $5) as point;", ["text", "text", "text", "text", "text"])
    return plpy.execute(internal_plan, [username, orgname, city_name, admin1_name, country_name])[0]['point']
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapbox_geocode_namedplace(username text, orgname text, city_name text, admin1_name text DEFAULT NULL, country_name text DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.mapbox import MapboxGeocoder
  from cartodb_services.metrics import QuotaService, metrics
  from cartodb_services.tools import Logger,LoggerConfig
  from cartodb_services.tools.country import country_to_iso3

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1}, {2})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname), plpy.quote_nullable('mapbox')))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('cdb_geocode_namedplace_point', user_geocoder_config, logger):
    try:
      geocoder = MapboxGeocoder(user_geocoder_config.mapbox_api_key, logger)

      country_iso3 = None
      if country_name:
        country_iso3 = country_to_iso3(country_name)

      coordinates = geocoder.geocode(searchtext=city_name, city=None,
                                     state_province=admin1_name,
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
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode city point using mapbox', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode city point using mapbox')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_geocode_namedplace(username text, orgname text, city_name text, admin1_name text DEFAULT NULL, country_name text DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.mapzen import MapzenGeocoder
  from cartodb_services.tools.country import country_to_iso3
  from cartodb_services.metrics import QuotaService, metrics
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1}, {2})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname), plpy.quote_nullable('mapzen')))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('cdb_geocode_namedplace_point', user_geocoder_config, logger):
    try:
      geocoder = MapzenGeocoder(user_geocoder_config.mapzen_api_key, logger)
      country_iso3 = None
      if country_name:
        country_iso3 = country_to_iso3(country_name)
      coordinates = geocoder.geocode(searchtext=city_name, city=None,
                                    state_province=admin1_name,
                                    country=country_iso3, search_type='locality')
      if coordinates:
        quota_service.increment_success_service_use()
        plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
        point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]
        return point['st_setsrid']
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode city point using mapzen', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode city point using mapzen')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapbox_isodistance(
   username TEXT,
   orgname TEXT,
   source geometry(Geometry, 4326),
   mode TEXT,
   data_range integer[],
   options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  import json
  from cartodb_services.mapbox import MapboxMatrixClient, MapboxIsolines
  from cartodb_services.mapbox.types import TRANSPORT_MODE_TO_MAPBOX
  from cartodb_services.tools import Coordinate
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_isolines_routing_config = GD["user_isolines_routing_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_isolines_routing_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
    client = MapboxMatrixClient(user_isolines_routing_config.mapbox_matrix_api_key, logger, user_isolines_routing_config.mapbox_matrix_service_params)
    mapbox_isolines = MapboxIsolines(client, logger)

    if source:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
      origin = Coordinate(lon,lat)
    else:
      raise Exception('source is NULL')

    profile = TRANSPORT_MODE_TO_MAPBOX.get(mode)

    # -- TODO Support options properly
    isolines = {}
    for r in data_range:
        isoline = mapbox_isolines.calculate_isodistance(origin, r, profile)
        isolines[r] = isoline

    result = []
    for r in data_range:

      if len(isolines[r]) >= 3:
        # -- TODO encapsulate this block into a func/method
        locations = isolines[r] + [ isolines[r][0] ] # close the polygon repeating the first point
        wkt_coordinates = ','.join(["%f %f" % (l.longitude, l.latitude) for l in locations])
        sql = "SELECT ST_MPolyFromText('MULTIPOLYGON((({0})))', 4326) as geom".format(wkt_coordinates)
        multipolygon = plpy.execute(sql, 1)[0]['geom']
      else:
        multipolygon = None

      result.append([source, r, multipolygon])

    quota_service.increment_success_service_use()
    quota_service.increment_isolines_service_use(len(isolines))
    return result
  except BaseException as e:
    import sys
    quota_service.increment_failed_service_use()
    logger.error('Error trying to get Mapbox isolines', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to get Mapbox isolines')
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapbox_isochrones(
   username TEXT,
   orgname TEXT,
   source geometry(Geometry, 4326),
   mode TEXT,
   data_range integer[],
   options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  import json
  from cartodb_services.mapbox import MapboxMatrixClient, MapboxIsolines
  from cartodb_services.mapbox.types import TRANSPORT_MODE_TO_MAPBOX
  from cartodb_services.tools import Coordinate
  from cartodb_services.tools.coordinates import coordinates_to_polygon
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_isolines_routing_config = GD["user_isolines_routing_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  # -- Check the quota
  quota_service = QuotaService(user_isolines_routing_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
    client = MapboxMatrixClient(user_isolines_routing_config.mapbox_matrix_api_key, logger, user_isolines_routing_config.mapbox_matrix_service_params)
    mapbox_isolines = MapboxIsolines(client, logger)

    if source:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
      origin = Coordinate(lon,lat)
    else:
      raise Exception('source is NULL')

    profile = TRANSPORT_MODE_TO_MAPBOX.get(mode)

    resp = mapbox_isolines.calculate_isochrone(origin, data_range, profile)

    if resp:
      result = []
      for isochrone in resp:
        result_polygon = coordinates_to_polygon(isochrone.coordinates)
        if result_polygon:
          quota_service.increment_success_service_use()
          result.append([source, isochrone.duration, result_polygon])
        else:
          quota_service.increment_empty_service_use()
          result.append([source, isochrone.duration, None])
      quota_service.increment_success_service_use()
      quota_service.increment_isolines_service_use(len(result))
      return result
    else:
      quota_service.increment_empty_service_use()
      return []
  except BaseException as e:
    import sys
    quota_service.increment_failed_service_use()
    logger.error('Error trying to get Mapbox isochrones', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to get Mapbox isochrones')
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_isodistance(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  if user_isolines_config.google_services_user:
    raise Exception('This service is not available for google service users.')

  with metrics('cb_isodistance', user_isolines_config, logger):
    if user_isolines_config.heremaps_provider:
      here_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_here_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(here_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapzen_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapzen_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapbox_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapbox_plan, [username, orgname, source, mode, range, options])
    else:
      raise Exception('Requested isolines provider is not available')
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

-- mapbox isodistance
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapbox_isodistance(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]

  mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapbox_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(mapbox_plan, [username, orgname, source, mode, range, options])

  return result
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_isochrone(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  if user_isolines_config.google_services_user:
    raise Exception('This service is not available for google service users.')

  with metrics('cb_isochrone', user_isolines_config, logger):
    if user_isolines_config.heremaps_provider:
      here_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_here_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(here_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapzen_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapzen_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapbox_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapbox_plan, [username, orgname, source, mode, range, options])
    else:
      raise Exception('Requested isolines provider is not available')
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

-- mapbox isochrone
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapbox_isochrone(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]

  mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapbox_isochrones($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(mapbox_plan, [username, orgname, source, mode, range, options])
  return result
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;
