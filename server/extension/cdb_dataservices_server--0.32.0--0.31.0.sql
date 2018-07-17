--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '<%= version %>'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade

ALTER TYPE cdb_dataservices_server.service_quota_info DROP ATTRIBUTE IF EXISTS max_batch_size;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_quota_info(
  username TEXT,
  orgname TEXT)
RETURNS SETOF cdb_dataservices_server.service_quota_info AS $$
  from cartodb_services.metrics.user import UserMetricsService
  from datetime import date

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']

  today = date.today()
  ret = []

  #-- Isolines
  service = 'isolines'
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
  user_service = UserMetricsService(user_isolines_config, redis_conn)

  monthly_quota = user_isolines_config.isolines_quota
  used_quota = user_service.used_quota(user_isolines_config.service_type, today)
  soft_limit = user_isolines_config.soft_isolines_limit
  provider = user_isolines_config.provider
  ret += [[service, monthly_quota, used_quota, soft_limit, provider]]

  #-- Hires Geocoder
  service = 'hires_geocoder'
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]
  user_service = UserMetricsService(user_geocoder_config, redis_conn)

  monthly_quota = user_geocoder_config.geocoding_quota
  used_quota = user_service.used_quota(user_geocoder_config.service_type, today)
  soft_limit = user_geocoder_config.soft_geocoding_limit
  provider = user_geocoder_config.provider
  ret += [[service, monthly_quota, used_quota, soft_limit, provider]]

  #-- Routing
  service = 'routing'
  plpy.execute("SELECT cdb_dataservices_server._get_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_routing_config = GD["user_routing_config_{0}".format(username)]
  user_service = UserMetricsService(user_routing_config, redis_conn)

  monthly_quota = user_routing_config.monthly_quota
  used_quota = user_service.used_quota(user_routing_config.service_type, today)
  soft_limit = user_routing_config.soft_limit
  provider = user_routing_config.provider
  ret += [[service, monthly_quota, used_quota, soft_limit, provider]]

  #-- Observatory
  service = 'observatory'
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]
  user_service = UserMetricsService(user_obs_config, redis_conn)

  monthly_quota = user_obs_config.monthly_quota
  used_quota = user_service.used_quota(user_obs_config.service_type, today)
  soft_limit = user_obs_config.soft_limit
  provider = user_obs_config.provider
  ret += [[service, monthly_quota, used_quota, soft_limit, provider]]

  return ret
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_bulk_geocode_street_point(TEXT, TEXT, jsonb);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_bulk_google_geocode_street_point(TEXT, TEXT, jsonb);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_bulk_heremaps_geocode_street_point(TEXT, TEXT, jsonb);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_bulk_tomtom_geocode_street_point(TEXT, TEXT, jsonb);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_bulk_mapbox_geocode_street_point(TEXT, TEXT, jsonb);
DROP TYPE IF EXISTS cdb_dataservices_server.geocoding;
