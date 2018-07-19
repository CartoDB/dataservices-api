DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type inner join pg_namespace ON (pg_type.typnamespace = pg_namespace.oid)
                 WHERE pg_type.typname = 'service_type'
                 AND pg_namespace.nspname = 'cdb_dataservices_server') THEN
    CREATE TYPE cdb_dataservices_server.service_type AS ENUM (
      'isolines',
      'hires_geocoder',
      'routing',
      'observatory'
    );
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type inner join pg_namespace ON (pg_type.typnamespace = pg_namespace.oid)
                 WHERE pg_type.typname = 'service_quota_info'
                 AND pg_namespace.nspname = 'cdb_dataservices_server') THEN
    CREATE TYPE cdb_dataservices_server.service_quota_info AS (
      service cdb_dataservices_server.service_type,
      monthly_quota NUMERIC,
      used_quota NUMERIC,
      soft_limit BOOLEAN,
      provider TEXT
    );
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type inner join pg_namespace ON (pg_type.typnamespace = pg_namespace.oid)
                 WHERE pg_type.typname = 'service_quota_info_batch'
                 AND pg_namespace.nspname = 'cdb_dataservices_server') THEN
    CREATE TYPE cdb_dataservices_server.service_quota_info_batch AS (
      service cdb_dataservices_server.service_type,
      monthly_quota NUMERIC,
      used_quota NUMERIC,
      soft_limit BOOLEAN,
      provider TEXT,
      max_batch_size NUMERIC
    );
  END IF;
END $$;


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


CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_quota_info_batch(
  username TEXT,
  orgname TEXT)
RETURNS SETOF cdb_dataservices_server.service_quota_info_batch AS $$
  from cartodb_services.bulk_geocoders import BATCH_GEOCODER_CLASS_BY_PROVIDER
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  sqi = plpy.execute("SELECT * from cdb_dataservices_server.cdb_service_quota_info({0},{1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))

  ret = []
  for info in sqi:
      if info['service'] == 'hires_geocoder':
          provider = info['provider']
          batch_geocoder_class = BATCH_GEOCODER_CLASS_BY_PROVIDER.get(provider, None)
          if batch_geocoder_class and hasattr(batch_geocoder_class, 'MAX_BATCH_SIZE'):
              max_batch_size = batch_geocoder_class.MAX_BATCH_SIZE
          else:
              max_batch_size = 1

          info['max_batch_size'] = max_batch_size
      else:
          info['max_batch_size'] = 1

      ret += [[info['service'], info['monthly_quota'], info['used_quota'], info['soft_limit'], info['provider'], info['max_batch_size']]]

  return ret
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_enough_quota(
  username TEXT,
  orgname TEXT,
  service_ TEXT,
  input_size NUMERIC)
returns BOOLEAN AS $$
  DECLARE
    params cdb_dataservices_server.service_quota_info;
  BEGIN
    SELECT * INTO params
      FROM cdb_dataservices_server.cdb_service_quota_info(username, orgname) AS p
      WHERE p.service = service_::cdb_dataservices_server.service_type;
    RETURN params.soft_limit OR ((params.used_quota + input_size) <= params.monthly_quota);
  END
$$ LANGUAGE plpgsql STABLE PARALLEL RESTRICTED;
