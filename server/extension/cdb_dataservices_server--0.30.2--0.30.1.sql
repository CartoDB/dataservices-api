--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.30.1'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
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
  from iso3166 import countries
  from cartodb_services.tools import ServiceManager
  from cartodb_services.mapbox import MapboxGeocoder
  from cartodb_services.tools.country import country_to_iso3
  from cartodb_services.refactor.service.mapbox_geocoder_config import MapboxGeocoderConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('geocoder', MapboxGeocoderConfigBuilder, username, orgname, GD)
  service_manager.assert_within_limits()

  try:
    geocoder = MapboxGeocoder(service_manager.config.mapbox_api_key, service_manager.logger, service_manager.config.service_params)

    country_iso3166 = None
    if country:
      country_iso3 = country_to_iso3(country)
      if country_iso3:
        country_iso3166 = countries.get(country_iso3).alpha2.lower()

    coordinates = geocoder.geocode(searchtext=searchtext, city=city,
                                   state_province=state_province,
                                   country=country_iso3166)
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
    service_manager.logger.error('Error trying to geocode street point using mapbox', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using mapbox')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;
