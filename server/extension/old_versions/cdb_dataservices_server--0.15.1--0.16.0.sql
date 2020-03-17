--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.16.0'" to load this file. \quit

-- Here goes your code to upgrade/downgrade

-- This is done in order to avoid an undesired depedency on cartodb extension
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_conf_getconf(input_key text)
RETURNS JSON AS $$
    SELECT VALUE FROM cartodb.cdb_conf WHERE key = input_key;
$$ LANGUAGE SQL STABLE SECURITY DEFINER;


CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  import cartodb_services
  cartodb_services.init(plpy, GD)
  from cartodb_services.mapzen import MapzenGeocoder
  from cartodb_services.mapzen.types import country_to_iso3
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger
  from cartodb_services.refactor.tools.logger import LoggerConfigBuilder
  from cartodb_services.refactor.service.mapzen_geocoder_config import MapzenGeocoderConfigBuilder
  from cartodb_services.refactor.core.environment import ServerEnvironmentBuilder
  from cartodb_services.refactor.backend.server_config import ServerConfigBackendFactory
  from cartodb_services.refactor.backend.user_config import UserConfigBackendFactory
  from cartodb_services.refactor.backend.org_config import OrgConfigBackendFactory
  from cartodb_services.refactor.backend.redis_metrics_connection import RedisMetricsConnectionFactory

  server_config_backend = ServerConfigBackendFactory().get()
  environment = ServerEnvironmentBuilder(server_config_backend).get()
  user_config_backend = UserConfigBackendFactory(username, environment, server_config_backend).get()
  org_config_backend = OrgConfigBackendFactory(orgname, environment, server_config_backend).get()

  logger_config = LoggerConfigBuilder(environment, server_config_backend).get()
  logger = Logger(logger_config)

  mapzen_geocoder_config = MapzenGeocoderConfigBuilder(server_config_backend, user_config_backend, org_config_backend, username, orgname).get()

  redis_metrics_connection = RedisMetricsConnectionFactory(environment, server_config_backend).get()

  quota_service = QuotaService(mapzen_geocoder_config, redis_metrics_connection)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  try:
    geocoder = MapzenGeocoder(mapzen_geocoder_config.mapzen_api_key, logger)
    country_iso3 = None
    if country:
      country_iso3 = country_to_iso3(country)
    coordinates = geocoder.geocode(searchtext=searchtext, city=city,
                                   state_province=state_province,
                                   country=country_iso3, search_type='address')
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
    logger.error('Error trying to geocode street point using mapzen', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using mapzen')
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;
