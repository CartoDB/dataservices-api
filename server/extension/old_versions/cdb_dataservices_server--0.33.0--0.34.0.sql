--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.34.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade

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

  params = {'username': username, 'orgname': orgname, 'origin': origin, 'destination': destination, 'mode': mode, 'options': options, 'units': units}

  with metrics('cdb_route_with_point', user_routing_config, logger, params):
    waypoints = [origin, destination]

    if user_routing_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(mapzen_plan, [username, orgname, waypoints, mode])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    elif user_routing_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapbox_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(mapbox_plan, [username, orgname, waypoints, mode])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    elif user_routing_config.tomtom_provider:
      tomtom_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_tomtom_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(tomtom_plan, [username, orgname, waypoints, mode])
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

  params = {'username': username, 'orgname': orgname, 'waypoints': waypoints, 'mode': mode, 'options': options, 'units': units}

  with metrics('cdb_route_with_waypoints', user_routing_config, logger, params):
    if user_routing_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(mapzen_plan, [username, orgname, waypoints, mode])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    elif user_routing_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapbox_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(mapbox_plan, [username, orgname, waypoints, mode])
      return [result[0]['shape'],result[0]['length'], result[0]['duration']]
    elif user_routing_config.tomtom_provider:
      tomtom_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_tomtom_route_with_waypoints($1, $2, $3, $4) as route;", ["text", "text", "geometry(Point, 4326)[]", "text"])
      result = plpy.execute(tomtom_plan, [username, orgname, waypoints, mode])
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

  params = {'username': username, 'orgname': orgname, 'searchtext': searchtext, 'city': city, 'state_province': state_province, 'country': country}

  with metrics('cdb_geocode_street_point', user_geocoder_config, logger, params):
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
    elif user_geocoder_config.tomtom_geocoder:
      tomtom_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_tomtom_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
      return plpy.execute(tomtom_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
    else:
      raise Exception('Requested geocoder is not available')

$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_bulk_geocode_street_point(username TEXT, orgname TEXT, searches jsonb)
RETURNS SETOF cdb_dataservices_server.geocoding AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']

  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  params = {'username': username, 'orgname': orgname, 'searches': searches}

  with metrics('cdb_bulk_geocode_street_point', user_geocoder_config, logger, params):
    if user_geocoder_config.google_geocoder:
      provider_function = "_cdb_bulk_google_geocode_street_point";
    elif user_geocoder_config.heremaps_geocoder:
      provider_function = "_cdb_bulk_heremaps_geocode_street_point";
    elif user_geocoder_config.tomtom_geocoder:
      provider_function = "_cdb_bulk_tomtom_geocode_street_point";
    elif user_geocoder_config.mapbox_geocoder:
      provider_function = "_cdb_bulk_mapbox_geocode_street_point";
    else:
      raise Exception('Requested geocoder is not available')

    plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.{}($1, $2, $3); ".format(provider_function), ["text", "text", "jsonb"])
    return plpy.execute(plan, [username, orgname, searches])

$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_admin0_polygon(username text, orgname text, country_name text)
RETURNS Geometry AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.metrics import InternalGeocoderConfig
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)

  params = {'username': username, 'orgname': orgname, 'country_name': country_name}

  with metrics('cdb_geocode_admin0_polygon', user_geocoder_config, logger, params):
    try:
      plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_admin0_polygon(trim($1)) AS mypolygon", ["text"])
      rv = plpy.execute(plan, [country_name], 1)
      result = rv[0]["mypolygon"]
      if result:
        quota_service.increment_success_service_use()
        return result
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode admin0 polygon', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode admin0 polygon')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_admin1_polygon(username text, orgname text, admin1_name text)
RETURNS Geometry AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.metrics import InternalGeocoderConfig
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)

  params = {'username': username, 'orgname': orgname, 'admin1_name': admin1_name}

  with metrics('cdb_geocode_admin1_polygon', user_geocoder_config, logger, params):
    try:
      plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_admin1_polygon(trim($1)) AS mypolygon", ["text"])
      rv = plpy.execute(plan, [admin1_name], 1)
      result = rv[0]["mypolygon"]
      if result:
        quota_service.increment_success_service_use()
        return result
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode admin1 polygon', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode admin1 polygon')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_internal_geocode_namedplace(username text, orgname text, city_name text, admin1_name text DEFAULT NULL, country_name text DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.metrics import InternalGeocoderConfig, metrics
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)

  params = {'username': username, 'orgname': orgname, 'city_name': city_name, 'admin1_name': admin1_name, 'country_name': country_name}

  with metrics('cdb_geocode_namedplace_point', user_geocoder_config, logger, params):
    try:
      if admin1_name and country_name:
        plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_namedplace_point(trim($1), trim($2), trim($3)) AS mypoint", ["text", "text", "text"])
        rv = plpy.execute(plan, [city_name, admin1_name, country_name], 1)
      elif country_name:
        plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_namedplace_point(trim($1), trim($2)) AS mypoint", ["text", "text"])
        rv = plpy.execute(plan, [city_name, country_name], 1)
      else:
        plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_namedplace_point(trim($1)) AS mypoint", ["text"])
        rv = plpy.execute(plan, [city_name], 1)
      result = rv[0]["mypoint"]
      if result:
        quota_service.increment_success_service_use()
        return result
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode namedplace point', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode namedplace point')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_point(username text, orgname text, code text)
RETURNS Geometry AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.metrics import InternalGeocoderConfig
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)

  params = {'username': username, 'orgname': orgname, 'code': code}

  with metrics('cdb_geocode_postalcode_point', user_geocoder_config, logger, params):
    try:
      plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_postalcode_point(trim($1)) AS mypoint", ["text"])
      rv = plpy.execute(plan, [code], 1)
      result = rv[0]["mypoint"]
      if result:
        quota_service.increment_success_service_use()
        return result
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode postal code point', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode postal code point')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_ipaddress_point(username text, orgname text, ip text)
RETURNS Geometry AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.metrics import InternalGeocoderConfig
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)

  params = {'username': username, 'orgname': orgname, 'ip': ip}

  with metrics('cdb_geocode_ipaddress_point', user_geocoder_config, logger):
    try:
      plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_ipaddress_point(trim($1)) AS mypoint", ["TEXT"])
      rv = plpy.execute(plan, [ip], 1)
      result = rv[0]["mypoint"]
      if result:
        quota_service.increment_success_service_use()
        return result
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to geocode postal code polygon', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to geocode postal code polygon')
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

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

  params = {'username': username, 'orgname': orgname, 'source': source, 'mode': mode, 'range': range, 'options': options}

  with metrics('cdb_isodistance', user_isolines_config, logger, params):
    if user_isolines_config.heremaps_provider:
      here_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_here_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(here_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapzen_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapzen_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapbox_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapbox_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.tomtom_provider:
      tomtom_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_tomtom_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(tomtom_plan, [username, orgname, source, mode, range, options])
    else:
      raise Exception('Requested isolines provider is not available')
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

  params = {'username': username, 'orgname': orgname, 'source': source, 'mode': mode, 'range': range, 'options': options}

  with metrics('cdb_isochrone', user_isolines_config, logger, params):
    if user_isolines_config.heremaps_provider:
      here_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_here_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(here_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapzen_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapzen_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapbox_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapbox_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.tomtom_provider:
      tomtom_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_tomtom_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(tomtom_plan, [username, orgname, source, mode, range, options])
    else:
      raise Exception('Requested isolines provider is not available')
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;
