--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.16.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
DROP FUNCTION IF EXISTS cdb_dataservices_server._get_metrics_logger_path(text);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  if user_geocoder_config.heremaps_geocoder:
    here_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_here_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
    return plpy.execute(here_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
  elif user_geocoder_config.google_geocoder:
    google_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_google_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
    return plpy.execute(google_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
  elif user_geocoder_config.mapzen_geocoder:
    mapzen_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapzen_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
    return plpy.execute(mapzen_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
  else:
    raise Exception('Requested geocoder is not available')

$$ LANGUAGE @@plpythonu@@;
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_admin0_polygon(username text, orgname text, country_name text)
RETURNS Geometry AS $$
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
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text)
RETURNS Geometry AS $$
  try:
    mapzen_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapzen_geocode_namedplace($1, $2, $3) as point;", ["text", "text", "text"])
    return plpy.execute(mapzen_plan, [username, orgname, city_name])[0]['point']
  except BaseException as e:
    internal_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_internal_geocode_namedplace($1, $2, $3) as point;", ["text", "text", "text"])
    return plpy.execute(internal_plan, [username, orgname, city_name])[0]['point']
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_admin1_polygon(username text, orgname text, admin1_name text)
RETURNS Geometry AS $$
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
$$ LANGUAGE @@plpythonu@@;

---- cdb_geocode_admin1_polygon(admin1_name text, country_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_admin1_polygon(username text, orgname text, admin1_name text, country_name text)
RETURNS Geometry AS $$
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

    try:
      plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_admin1_polygon(trim($1), trim($2)) AS mypolygon", ["text", "text"])
      rv = plpy.execute(plan, [admin1_name, country_name], 1)
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
$$ LANGUAGE @@plpythonu@@;

---- cdb_geocode_namedplace_point(city_name text, country_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text, country_name text)
RETURNS Geometry AS $$
  try:
    mapzen_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapzen_geocode_namedplace($1, $2, $3, NULL, $4) as point;", ["text", "text", "text", "text"])
    return plpy.execute(mapzen_plan, [username, orgname, city_name, country_name])[0]['point']
  except BaseException as e:
    internal_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_internal_geocode_namedplace($1, $2, $3, NULL, $4) as point;", ["text", "text", "text", "text"])
    return plpy.execute(internal_plan, [username, orgname, city_name, country_name])[0]['point']
$$ LANGUAGE @@plpythonu@@;

---- cdb_geocode_namedplace_point(city_name text, admin1_name text, country_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text, admin1_name text, country_name text)
RETURNS Geometry AS $$
  try:
    mapzen_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapzen_geocode_namedplace($1, $2, $3, $4, $5) as point;", ["text", "text", "text", "text", "text"])
    return plpy.execute(mapzen_plan, [username, orgname, city_name, admin1_name, country_name])[0]['point']
  except BaseException as e:
    internal_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_internal_geocode_namedplace($1, $2, $3, $4, $5) as point;", ["text", "text", "text", "text", "text"])
    return plpy.execute(internal_plan, [username, orgname, city_name, admin1_name, country_name])[0]['point']
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_point(username text, orgname text, code text)
RETURNS Geometry AS $$
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
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_point(username text, orgname text, code text, country text)
RETURNS Geometry AS $$
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
  try:
    plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_postalcode_point(trim($1), trim($2)) AS mypoint", ["TEXT", "TEXT"])
    rv = plpy.execute(plan, [code, country], 1)
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
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_polygon(username text, orgname text, code text)
RETURNS Geometry AS $$
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
  try:
    plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_postalcode_polygon(trim($1)) AS mypolygon", ["text"])
    rv = plpy.execute(plan, [code], 1)
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
    logger.error('Error trying to geocode postal code polygon', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode postal code polygon')
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_polygon(username text, orgname text, code text, country text)
RETURNS Geometry AS $$
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
  try:
    plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_postalcode_polygon(trim($1), trim($2)) AS mypolygon", ["TEXT", "TEXT"])
    rv = plpy.execute(plan, [code, country], 1)
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
    logger.error('Error trying to geocode postal code polygon', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode postal code polygon')
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_ipaddress_point(username text, orgname text, ip text)
RETURNS Geometry AS $$
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
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_isochrone(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]

  if user_isolines_config.google_services_user:
    raise Exception('This service is not available for google service users.')

  if user_isolines_config.heremaps_provider:
    here_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_here_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
    return plpy.execute(here_plan, [username, orgname, source, mode, range, options])
  elif user_isolines_config.mapzen_provider:
    mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapzen_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
    return plpy.execute(mapzen_plan, [username, orgname, source, mode, range, options])
  else:
    raise Exception('Requested isolines provider is not available')
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_route_point_to_point(
  username TEXT,
  orgname TEXT,
  origin geometry(Point, 4326),
  destination geometry(Point, 4326),
  mode TEXT,
  options text[] DEFAULT ARRAY[]::text[],
  units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_server.simple_route AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_routing_config = GD["user_routing_config_{0}".format(username)]

  waypoints = [origin, destination]
  mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_route_with_waypoints($1, $2, $3, $4, $5, $6) as route;", ["text", "text", "geometry(Point, 4326)[]", "text", "text[]", "text"])
  result = plpy.execute(mapzen_plan, [username, orgname, waypoints, mode, options, units])
  return [result[0]['shape'],result[0]['length'], result[0]['duration']]
$$ LANGUAGE @@plpythonu@@;


CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_route_with_waypoints(
  username TEXT,
  orgname TEXT,
  waypoints geometry(Point, 4326)[],
  mode TEXT,
  options text[] DEFAULT ARRAY[]::text[],
  units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_server.simple_route AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_routing_config = GD["user_routing_config_{0}".format(username)]

  mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_route_with_waypoints($1, $2, $3, $4, $5, $6) as route;", ["text", "text", "geometry(Point, 4326)[]", "text", "text[]", "text"])
  result = plpy.execute(mapzen_plan, [username, orgname, waypoints, mode, options, units])
  return [result[0]['shape'],result[0]['length'], result[0]['duration']]
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_get_demographic_snapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL,
  geometry_level TEXT DEFAULT NULL)
RETURNS json AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig
  import json

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_snapshot_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_snapshot_config = GD["user_obs_snapshot_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_snapshot_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetDemographicSnapshotJSON($1, $2, $3, $4, $5) as snapshot;", ["text", "text", "geometry(Geometry, 4326)", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, time_span, geometry_level])
      if result:
        quota_service.increment_success_service_use()
        return result[0]['snapshot']
      else:
        quota_service.increment_empty_service_use()
        return None
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to obs_get_demographic_snapshot', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to obs_get_demographic_snapshot')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetDemographicSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL,
  geometry_level TEXT DEFAULT NULL)
RETURNS SETOF JSON AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_snapshot_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_snapshot_config = GD["user_obs_snapshot_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_snapshot_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetDemographicSnapshot($1, $2, $3, $4, $5) as snapshot;", ["text", "text", "geometry(Geometry, 4326)", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, time_span, geometry_level])
      if result:
        resp = []
        for element in result:
          value = element['snapshot']
          resp.append(value)
        quota_service.increment_success_service_use()
        return resp
      else:
        quota_service.increment_empty_service_use()
        return []
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to obs_get_demographic_snapshot', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to obs_get_demographic_snapshot')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_get_segment_snapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT NULL)
RETURNS json AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig
  import json

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_snapshot_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_snapshot_config = GD["user_obs_snapshot_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_snapshot_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetSegmentSnapshotJSON($1, $2, $3, $4) as snapshot;", ["text", "text", "geometry(Geometry, 4326)", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, geometry_level])
      if result:
        quota_service.increment_success_service_use()
        return result[0]['snapshot']
      else:
        quota_service.increment_empty_service_use()
        return None
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to obs_get_segment_snapshot', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to obs_get_segment_snapshot')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetSegmentSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT NULL)
RETURNS SETOF JSON AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_snapshot_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_snapshot_config = GD["user_obs_snapshot_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_snapshot_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetSegmentSnapshot($1, $2, $3, $4) as snapshot;", ["text", "text", "geometry(Geometry, 4326)", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, geometry_level])
      if result:
        resp = []
        for element in result:
          value = element['snapshot']
          resp.append(value)
        quota_service.increment_success_service_use()
        return resp
      else:
        quota_service.increment_empty_service_use()
        return []
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_GetSegmentSnapshot', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_GetSegmentSnapshot')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetMeasure(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  measure_id TEXT,
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetMeasure($1, $2, $3, $4, $5, $6, $7) as measure;", ["text", "text", "geometry(Geometry, 4326)", "text", "text", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, measure_id, normalize, boundary_id, time_span])
      if result:
        quota_service.increment_success_service_use()
        return result[0]['measure']
      else:
        quota_service.increment_empty_service_use()
        return None
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_GetMeasure', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_GetMeasure')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetCategory(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  category_id TEXT,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetCategory($1, $2, $3, $4, $5, $6) as category;", ["text", "text", "geometry(Geometry, 4326)", "text", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, category_id, boundary_id, time_span])
      if result:
        quota_service.increment_success_service_use()
        return result[0]['category']
      else:
        quota_service.increment_empty_service_use()
        return None
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_GetCategory', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_GetCategory')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetUSCensusMeasure(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  name TEXT,
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetUSCensusMeasure($1, $2, $3, $4, $5, $6, $7) as census_measure;", ["text", "text", "geometry(Geometry, 4326)", "text", "text", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, name, normalize, boundary_id, time_span])
      if result:
        quota_service.increment_success_service_use()
        return result[0]['census_measure']
      else:
        quota_service.increment_empty_service_use()
        return None
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_GetUSCensusMeasure', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_GetUSCensusMeasure')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetUSCensusCategory(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  name TEXT,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetUSCensusCategory($1, $2, $3, $4, $5, $6) as census_category;", ["text", "text", "geometry(Geometry, 4326)", "text", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, name, boundary_id, time_span])
      if result:
        quota_service.increment_success_service_use()
        return result[0]['census_category']
      else:
        quota_service.increment_empty_service_use()
        return None
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_GetUSCensusCategory', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_GetUSCensusCategory')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetPopulation(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetPopulation($1, $2, $3, $4, $5, $6) as population;", ["text", "text", "geometry(Geometry, 4326)", "text", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, normalize, boundary_id, time_span])
      if result:
        quota_service.increment_success_service_use()
        return result[0]['population']
      else:
        quota_service.increment_empty_service_use()
        return None
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_GetPopulation', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_GetPopulation')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetMeasureById(
  username TEXT,
  orgname TEXT,
  geom_ref TEXT,
  measure_id TEXT,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetMeasureById($1, $2, $3, $4, $5, $6) as measure;", ["text", "text", "text", "text", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom_ref, measure_id, boundary_id, time_span])
      if result:
        quota_service.increment_success_service_use()
        return result[0]['measure']
      else:
        quota_service.increment_empty_service_use()
        return None
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_GetMeasureById', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_GetMeasureById')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_Search(
  username TEXT,
  orgname TEXT,
  search_term TEXT,
  relevant_boundary TEXT DEFAULT NULL)
RETURNS TABLE(id text, description text, name text, aggregate text, source text) AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_Search($1, $2, $3, $4);", ["text", "text", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, search_term, relevant_boundary])
      if result:
        resp = []
        for element in result:
          id = element['id']
          description = element['description']
          name = element['name']
          aggregate = element['aggregate']
          source = element['source']
          resp.append([id, description, name, aggregate, source])
        quota_service.increment_success_service_use()
        return resp
      else:
        quota_service.increment_empty_service_use()
        return [None, None, None, None, None]
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_Search', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_Search')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableBoundaries(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL)
RETURNS TABLE(boundary_id text, description text, time_span text, tablename text) AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetAvailableBoundaries($1, $2, $3, $4) as available_boundaries;", ["text", "text", "geometry(Geometry, 4326)", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, time_span])
      if result:
        resp = []
        for element in result:
          id = element['boundary_id']
          description = element['description']
          tspan = element['time_span']
          tablename = element['tablename']
          resp.append([id, description, tspan, tablename])
        quota_service.increment_success_service_use()
        return resp
      else:
        quota_service.increment_empty_service_use()
        return []
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_GetMeasureById', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_GetMeasureById')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundary(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS geometry(Geometry, 4326) AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetBoundary($1, $2, $3, $4) as boundary;", ["text", "text", "geometry(Point, 4326)", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, boundary_id, time_span])
      if result:
        quota_service.increment_success_service_use()
        return result[0]['boundary']
      else:
        quota_service.increment_empty_service_use()
        return None
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_GetBoundary', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_GetBoundary')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundaryId(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetBoundaryId($1, $2, $3, $4, $5) as boundary;", ["text", "text", "geometry(Point, 4326)", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, boundary_id, time_span])
      if result:
        quota_service.increment_success_service_use()
        return result[0]['boundary']
      else:
        quota_service.increment_empty_service_use()
        return None
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_GetBoundaryId', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_GetBoundaryId')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundaryById(
  username TEXT,
  orgname TEXT,
  geometry_id TEXT,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS geometry(Geometry, 4326) AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetBoundaryById($1, $2, $3, $4, $5) as boundary;", ["text", "text", "text", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geometry_id, boundary_id, time_span])
      if result:
        quota_service.increment_success_service_use()
        return result[0]['boundary']
      else:
        quota_service.increment_empty_service_use()
        return None
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_GetBoundaryById', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_GetBoundaryById')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundariesByGeometry(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetBoundariesByGeometry($1, $2, $3, $4, $5, $6) as boundary;", ["text", "text", "geometry(Point, 4326)", "text", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, boundary_id, time_span, overlap_type])
      if result:
        resp = []
        for element in result:
          the_geom = element['the_geom']
          geom_refs = element['geom_refs']
          resp.append([the_geom, geom_refs])
        quota_service.increment_success_service_use()
        return resp
      else:
        quota_service.increment_empty_service_use()
        return []
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_GetBoundariesByGeometry', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_GetBoundariesByGeometry')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundariesByPointAndRadius(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  radius NUMERIC,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetBoundariesByPointAndRadius($1, $2, $3, $4, $5, $6, $7) as boundary;", ["text", "text", "geometry(Point, 4326)", "numeric", "text", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, radius, boundary_id, time_span, overlap_type])
      if result:
        resp = []
        for element in result:
          the_geom = element['the_geom']
          geom_refs = element['geom_refs']
          resp.append([the_geom, geom_refs])
        quota_service.increment_success_service_use()
        return resp
      else:
        quota_service.increment_empty_service_use()
        return []
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_GetBoundariesByPointAndRadius', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_GetBoundariesByPointAndRadius')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetPointsByGeometry(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetPointsByGeometry($1, $2, $3, $4, $5, $6) as boundary;", ["text", "text", "geometry(Point, 4326)", "text", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, boundary_id, time_span, overlap_type])
      if result:
        resp = []
        for element in result:
          the_geom = element['the_geom']
          geom_refs = element['geom_refs']
          resp.append([the_geom, geom_refs])
        quota_service.increment_success_service_use()
        return resp
      else:
        quota_service.increment_empty_service_use()
        return []
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_GetPointsByGeometry', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_GetPointsByGeometry')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetPointsByPointAndRadius(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  radius NUMERIC,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetPointsByPointAndRadius($1, $2, $3, $4, $5, $6, $7) as boundary;", ["text", "text", "geometry(Point, 4326)", "numeric", "text", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, radius, boundary_id, time_span, overlap_type])
      if result:
        resp = []
        for element in result:
          the_geom = element['the_geom']
          geom_refs = element['geom_refs']
          resp.append([the_geom, geom_refs])
        quota_service.increment_success_service_use()
        return resp
      else:
        quota_service.increment_empty_service_use()
        return None
  except BaseException as e:
      import sys
      quota_service.increment_failed_service_use()
      logger.error('Error trying to OBS_GetPointsByPointAndRadius', sys.exc_info(), data={"username": username, "orgname": orgname})
      raise Exception('Error trying to OBS_GetPointsByPointAndRadius')
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@;
