-- TODO: could cartodb_id be replaced by rowid, maybe needing extra care for offset?
CREATE TYPE cdb_dataservices_server.geocoding AS (
    cartodb_id integer,
    the_geom geometry(Multipolygon,4326),
    metadata jsonb
);

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

  params = {'searches': searches}

  with metrics('cdb_bulk_geocode_street_point', user_geocoder_config, logger, params):
    if user_geocoder_config.google_geocoder:
      google_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_bulk_google_geocode_street_point($1, $2, $3); ", ["text", "text", "jsonb"])
      result = plpy.execute(google_plan, [username, orgname, searches])
      return result
    else:
      raise Exception('Requested geocoder is not available')

$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_bulk_google_geocode_street_point(username TEXT, orgname TEXT, searches jsonb)
RETURNS SETOF cdb_dataservices_server.geocoding AS $$
  from cartodb_services.tools import LegacyServiceManager,QuotaExceededException,Logger
  from cartodb_services.google import GoogleMapsGeocoder

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]

  logger = Logger(logger_config)
  service_manager = LegacyServiceManager('geocoder', username, orgname, GD)

  try:
    service_manager.assert_within_limits(quota=False)
    geocoder = GoogleMapsGeocoder(service_manager.config.google_client_id, service_manager.config.google_api_key, service_manager.logger)
    geocode_results = geocoder.bulk_geocode(searches=searches)
    if geocode_results:
      results = []
      for result in geocode_results:
        if result[1]:
          plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326) as the_geom; ", ["double precision", "double precision"])
          point = plpy.execute(plan, result[1], 1)[0]
          results.append([result[0], point['the_geom'], None])
        else:
          results.append([result[0], None, None])
      service_manager.quota_service.increment_success_service_use(len(results))
      return results
    else:
      service_manager.quota_service.increment_empty_service_use(len(searches))
      return []
  except QuotaExceededException as qe:
    service_manager.quota_service.increment_failed_service_use(len(searches))
    return []
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to bulk geocode street point using google maps', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to bulk geocode street point using google maps')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

