CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_monthly_quota(
  username TEXT,
  orgname TEXT,
  service TEXT)
RETURNS integer AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']

  if service == 'isolines':
    plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
    user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
    return user_isolines_config.isolines_quota
  else:
    raise 'not implemented'
$$ LANGUAGE plpythonu;


CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_remaining_quota(
  username TEXT,
  orgname TEXT,
  service TEXT)
RETURNS integer AS $$
  from datetime import date
  from cartodb_services.metrics.user import UserMetricsService

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']

  if service == 'isolines':
    plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
    user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
    monthly_quota = user_isolines_config.isolines_quota

    user_service = UserMetricsService(user_isolines_config, redis_conn)
    current_used = user_service.used_quota(user_isolines_config.service_type, date.today())
    return monthly_quota - current_used
  else:
    raise 'not implemented'
$$ LANGUAGE plpythonu;


CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_soft_limit(
  username TEXT,
  orgname TEXT,
  service TEXT)
RETURNS boolean AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']

  if service == 'isolines':
    plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
    user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
    return user_isolines_config.soft_isolines_limit
  else:
    raise 'not implemented'
$$ LANGUAGE plpythonu;


CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_provider(
  username TEXT,
  orgname TEXT,
  service TEXT)
RETURNS TEXT AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']

  if service == 'isolines':
    plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
    user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
    return user_isolines_config.provider
  else:
    raise 'not implemented'
$$ LANGUAGE plpythonu;
