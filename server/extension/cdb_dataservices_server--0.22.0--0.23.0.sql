--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.23.0'" to load this file. \quit

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_get_rate_limit(
  username TEXT,
  orgname TEXT,
  service TEXT)
RETURNS JSON AS $$
  import json
  from cartodb_services.config import ServiceConfiguration, RateLimitsConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_config = ServiceConfiguration(service, username, orgname)
  rate_limit_config = RateLimitsConfigBuilder(service_config.server, service_config.user, service_config.org, service=service, username=username, orgname=orgname).get()
  if rate_limit_config.is_limited():
      return json.dumps({'limit': rate_limit_config.limit, 'period': rate_limit_config.period})
  else:
      return None
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_set_user_rate_limit(
  username TEXT,
  orgname TEXT,
  service TEXT,
  rate_limit_json JSON)
RETURNS VOID AS $$
  import json
  from cartodb_services.config import RateLimitsConfig, RateLimitsConfigSetter

  import cartodb_services
  cartodb_services.init(plpy, GD)

  config_setter = RateLimitsConfigSetter(service=service, username=username, orgname=orgname)
  if rate_limit_json:
      rate_limit = json.loads(rate_limit_json)
      limit = rate_limit.get('limit', None)
      period = rate_limit.get('period', None)
  else:
      limit = None
      period = None
  config = RateLimitsConfig(service=service, username=username, limit=limit, period=period)
  config_setter.set_user_rate_limits(config)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_set_org_rate_limit(
  username TEXT,
  orgname TEXT,
  service TEXT,
  rate_limit_json JSON)
RETURNS VOID AS $$
  import json
  from cartodb_services.config import RateLimitsConfig, RateLimitsConfigSetter

  import cartodb_services
  cartodb_services.init(plpy, GD)

  config_setter = RateLimitsConfigSetter(service=service, username=username, orgname=orgname)
  if rate_limit_json:
      rate_limit = json.loads(rate_limit_json)
      limit = rate_limit.get('limit', None)
      period = rate_limit.get('period', None)
  else:
      limit = None
      period = None
  config = RateLimitsConfig(service=service, username=username, limit=limit, period=period)
  config_setter.set_org_rate_limits(config)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_set_server_rate_limit(
  username TEXT,
  orgname TEXT,
  service TEXT,
  rate_limit_json JSON)
RETURNS VOID AS $$
  import json
  from cartodb_services.config import RateLimitsConfig, RateLimitsConfigSetter

  import cartodb_services
  cartodb_services.init(plpy, GD)

  config_setter = RateLimitsConfigSetter(service=service, username=username, orgname=orgname)
  if rate_limit_json:
      rate_limit = json.loads(rate_limit_json)
      limit = rate_limit.get('limit', None)
      period = rate_limit.get('period', None)
  else:
      limit = None
      period = None
  config = RateLimitsConfig(service=service, username=username, limit=limit, period=period)
  config_setter.set_server_rate_limits(config)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE
FUNCTION cdb_dataservices_server.CDB_Conf_SetConf(key text, value JSON)
    RETURNS void AS $$
BEGIN
    PERFORM cartodb.CDB_Conf_RemoveConf(key);
    EXECUTE 'INSERT INTO cartodb.CDB_CONF (KEY, VALUE) VALUES ($1, $2);' USING key, value;
END
$$ LANGUAGE PLPGSQL VOLATILE;

CREATE OR REPLACE
FUNCTION cdb_dataservices_server.CDB_Conf_RemoveConf(key text)
    RETURNS void AS $$
BEGIN
    EXECUTE 'DELETE FROM cartodb.CDB_CONF WHERE KEY = $1;' USING key;
END
$$ LANGUAGE PLPGSQL VOLATILE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_here_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.tools import LegacyServiceManager
  from cartodb_services.here import HereMapsGeocoder

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  service_manager = LegacyServiceManager('geocoder', username, orgname, GD)
  service_manager.assert_within_limits()

  try:
    geocoder = HereMapsGeocoder(service_manager.config.heremaps_app_id, service_manager.config.heremaps_app_code, service_manager.logger, service_manager.config.heremaps_service_params)
    coordinates = geocoder.geocode(searchtext=searchtext, city=city, state=state_province, country=country)
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
    service_manager.logger.error('Error trying to geocode street point using here maps', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using here maps')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_google_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.tools import LegacyServiceManager
  from cartodb_services.google import GoogleMapsGeocoder

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  service_manager = LegacyServiceManager('geocoder', username, orgname, GD)
  service_manager.assert_within_limits(quota=False)

  try:
    geocoder = GoogleMapsGeocoder(service_manager.config.google_client_id, service_manager.config.google_api_key, service_manager.logger)
    coordinates = geocoder.geocode(searchtext=searchtext, city=city, state=state_province, country=country)
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
    service_manager.logger.error('Error trying to geocode street point using google maps', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using google maps')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.tools import ServiceManager
  from cartodb_services.mapzen import MapzenGeocoder
  from cartodb_services.mapzen.types import country_to_iso3
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
$$ LANGUAGE plpythonu;
