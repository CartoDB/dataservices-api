CREATE TYPE cdb_dataservices_server.service_params AS (
  monthly_quota NUMERIC,
  used_quota NUMERIC,
  soft_limit BOOLEAN,
  provider TEXT
);


CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_params(
  username TEXT,
  orgname TEXT,
  service TEXT)
RETURNS cdb_dataservices_server.service_params AS $$
  import cartodb_services.metrics.quota as quota
  from cartodb_services.metrics.user import UserMetricsService
  from datetime import date

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']

  today = date.today()

  if service == quota.Service.ISOLINES:
    plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
    user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
    user_service = UserMetricsService(user_isolines_config, redis_conn)

    monthly_quota = user_isolines_config.isolines_quota
    used_quota = user_service.used_quota(user_isolines_config.service_type, today)
    soft_limit = user_isolines_config.soft_isolines_limit
    provider = user_isolines_config.provider
  elif service == quota.Service.HIRES_GEOCODER:
    plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
    user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]
    user_service = UserMetricsService(user_geocoder_config, redis_conn)

    monthly_quota = user_geocoder_config.geocoding_quota
    used_quota = user_service.used_quota(user_geocoder_config, today)
    soft_limit = user_geocoder_config.soft_geocoding_limit
    provider = user_geocoder_config.provider
  else:
    raise 'not implemented'

  return [monthly_quota, used_quota, soft_limit, provider]

$$ LANGUAGE plpythonu;
