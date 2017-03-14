-- Geocodes a street address given a searchtext and a state and/or country
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
    else:
      raise Exception('Requested geocoder is not available')

$$ LANGUAGE plpythonu;


CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_here_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  if user_geocoder_config.heremaps_geocoder:
    here_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_here_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
    return plpy.execute(here_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
  else:
    raise Exception('Here geocoder is not available for your account.')

$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_google_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  if user_geocoder_config.google_geocoder:
    google_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_google_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
    return plpy.execute(google_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']
  else:
    raise Exception('Google geocoder is not available for your account.')

$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapzen_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  # The configuration is retrieved but no checks are performed on it
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  mapzen_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_mapzen_geocode_street_point($1, $2, $3, $4, $5, $6) as point; ", ["text", "text", "text", "text", "text", "text"])
  return plpy.execute(mapzen_plan, [username, orgname, searchtext, city, state_province, country], 1)[0]['point']

$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_here_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.tools import ServiceManager
  from cartodb_services.here import HereMapsGeocoder

  # from cartodb_services.metrics import QuotaService
  # from cartodb_services.tools import Logger,LoggerConfig
  # from cartodb_services.tools import RateLimiter
  # from cartodb_services.refactor.config.rate_limits import RateLimitsConfig

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  service_manager = LegacyServiceManager('geocoder', username, orgname, GD)
  service_manager.check()

  try:
    geocoder = HereMapsGeocoder(user_geocoder_config.heremaps_app_id, user_geocoder_config.heremaps_app_code, logger, user_geocoder_config.heremaps_service_params)
    coordinates = geocoder.geocode(searchtext=searchtext, city=city, state=state_province, country=country)
    if coordinates:
      quota_service.increment_success_service_use()
      plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
      point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]
      return point['st_setsrid']
    else:
      service_manager.quota_service.increment_empty_service_use()
      return None
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    logger.error('Error trying to geocode street point using here maps', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using here maps')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_google_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.google import GoogleMapsGeocoder
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)

  try:
    geocoder = GoogleMapsGeocoder(user_geocoder_config.google_client_id, user_geocoder_config.google_api_key, logger)
    coordinates = geocoder.geocode(searchtext=searchtext, city=city, state=state_province, country=country)
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
    logger.error('Error trying to geocode street point using google maps', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using google maps')
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.tools import ServiceManager
  from cartodb_services.mapzen import MapzenGeocoder
  from cartodb_services.mapzen.types import country_to_iso3
  from cartodb_services.refactor.service.mapzen_geocoder_config import MapzenGeocoderConfigBuilder
  # from cartodb_services.metrics import QuotaService
  # from cartodb_services.tools import Logger
  # from cartodb_services.tools import RateLimiter
  # from cartodb_services.refactor.tools.logger import LoggerConfigBuilder
  # from cartodb_services.refactor.core.environment import ServerEnvironmentBuilder
  # from cartodb_services.refactor.backend.server_config import ServerConfigBackendFactory
  # from cartodb_services.refactor.backend.user_config import UserConfigBackendFactory
  # from cartodb_services.refactor.backend.org_config import OrgConfigBackendFactory
  # from cartodb_services.refactor.backend.redis_metrics_connection import RedisMetricsConnectionFactory
  # from cartodb_services.refactor.config.rate_limits import RateLimitsConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('geocoder', MapzenGeocoderConfigBuilder, username, orgname)
  service_manager.check()

  try:
    geocoder = MapzenGeocoder(mapzen_geocoder_config.mapzen_api_key, logger, mapzen_geocoder_config.service_params)
    country_iso3 = None
    if country:
      untry_iso3 = country_to_iso3(country)
    coordinates = geocoder.geocode(searchtext=searchtext, city=city,
                                   state_province=state_province,
                                   country=country_iso3, search_type='address')
    if coordinates:
      service_manager.quota_service.quota_service.increment_success_service_use()
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
