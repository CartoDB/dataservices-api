-- TODO: could cartodb_id be replaced by rowid, maybe needing extra care for offset?
CREATE TYPE cdb_dataservices_server.geocoding AS (
    cartodb_id integer,
    the_geom geometry(Multipolygon,4326),
    metadata jsonb
);

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_bulk_geocode_street_point(username TEXT, orgname TEXT, appname TEXT, searches jsonb)
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

  params = {'searches': searches}

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

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_bulk_google_geocode_street_point(username TEXT, orgname TEXT, searches jsonb)
RETURNS SETOF cdb_dataservices_server.geocoding AS $$
  from cartodb_services import run_street_point_geocoder
  from cartodb_services.tools import LegacyServiceManager
  from cartodb_services.google import GoogleMapsBulkGeocoder

  service_manager = LegacyServiceManager('geocoder', username, orgname, GD)
  geocoder = GoogleMapsBulkGeocoder(service_manager.config.google_client_id, service_manager.config.google_api_key, service_manager.logger)
  return run_street_point_geocoder(plpy, GD, geocoder, service_manager, username, orgname, searches)
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_bulk_heremaps_geocode_street_point(username TEXT, orgname TEXT, searches jsonb)
RETURNS SETOF cdb_dataservices_server.geocoding AS $$
  from cartodb_services import run_street_point_geocoder
  from cartodb_services.tools import LegacyServiceManager
  from cartodb_services.here import HereMapsBulkGeocoder

  service_manager = LegacyServiceManager('geocoder', username, orgname, GD)
  geocoder = HereMapsBulkGeocoder(service_manager.config.heremaps_app_id, service_manager.config.heremaps_app_code, service_manager.logger, service_manager.config.heremaps_service_params)
  return run_street_point_geocoder(plpy, GD, geocoder, service_manager, username, orgname, searches)
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_bulk_tomtom_geocode_street_point(username TEXT, orgname TEXT, searches jsonb)
RETURNS SETOF cdb_dataservices_server.geocoding AS $$
  from cartodb_services import run_street_point_geocoder
  from cartodb_services.tools import ServiceManager
  from cartodb_services.refactor.service.tomtom_geocoder_config import TomTomGeocoderConfigBuilder
  from cartodb_services.tomtom import TomTomBulkGeocoder
  from cartodb_services.tools import Logger
  import cartodb_services
  cartodb_services.init(plpy, GD)

  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  service_manager = ServiceManager('geocoder', TomTomGeocoderConfigBuilder, username, orgname, GD)
  geocoder = TomTomBulkGeocoder(service_manager.config.tomtom_api_key, service_manager.logger, service_manager.config.service_params)
  return run_street_point_geocoder(plpy, GD, geocoder, service_manager, username, orgname, searches)
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_bulk_mapbox_geocode_street_point(username TEXT, orgname TEXT, searches jsonb)
RETURNS SETOF cdb_dataservices_server.geocoding AS $$
  from cartodb_services import run_street_point_geocoder
  from cartodb_services.tools import ServiceManager
  from cartodb_services.refactor.service.mapbox_geocoder_config import MapboxGeocoderConfigBuilder
  from cartodb_services.mapbox import MapboxBulkGeocoder
  from cartodb_services.tools import Logger
  import cartodb_services
  cartodb_services.init(plpy, GD)

  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  service_manager = ServiceManager('geocoder', MapboxGeocoderConfigBuilder, username, orgname, GD)
  geocoder = MapboxBulkGeocoder(service_manager.config.mapbox_api_key, service_manager.logger, service_manager.config.service_params)
  return run_street_point_geocoder(plpy, GD, geocoder, service_manager, username, orgname, searches)
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

