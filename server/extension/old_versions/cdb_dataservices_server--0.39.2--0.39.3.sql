--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.39.3'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_tomtom_geocode_street_point(username TEXT, orgname TEXT, searchtext TEXT, city TEXT DEFAULT NULL, state_province TEXT DEFAULT NULL, country TEXT DEFAULT NULL)
RETURNS Geometry AS $$
  from cartodb_services.tools import ServiceManager, QuotaExceededException
  from cartodb_services.tomtom import TomTomGeocoder
  from cartodb_services.refactor.service.tomtom_geocoder_config import TomTomGeocoderConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('geocoder', TomTomGeocoderConfigBuilder, username, orgname, GD)

  try:
    service_manager.assert_within_limits()
    geocoder = TomTomGeocoder(service_manager.config.tomtom_api_key, service_manager.logger, service_manager.config.service_params)

    coordinates = geocoder.geocode(searchtext=searchtext, city=city,
                                   state_province=state_province,
                                   country=country)
    if coordinates:
      service_manager.quota_service.increment_success_service_use()
      plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326); ", ["double precision", "double precision"])
      point = plpy.execute(plan, [coordinates[0], coordinates[1]], 1)[0]
      return point['st_setsrid']
    else:
      service_manager.quota_service.increment_empty_service_use()
      return None
  except QuotaExceededException as qe:
    service_manager.quota_service.increment_failed_service_use()
    return None
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to geocode street point using TomTom', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode street point using TomTom')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;
