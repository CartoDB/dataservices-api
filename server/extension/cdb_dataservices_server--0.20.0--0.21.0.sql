--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.21.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetData(
  username TEXT,
  orgname TEXT,
  geomvals geomval[],
  params JSON,
  merge BOOLEAN DEFAULT True)
RETURNS TABLE (
  id INT,
  data JSON
) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetData(geomvals, params, merge);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetData(
  username TEXT,
  orgname TEXT,
  geomvals geomval[],
  params JSON,
  merge BOOLEAN DEFAULT True)
RETURNS TABLE (
  id INT,
  data JSON
) AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getdata', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetData($1, $2, $3, $4, $5);", ["text", "text", "geomval[]", "json", "boolean"])
        result = plpy.execute(obs_plan, [username, orgname, geomvals, params, merge])
        if result:
          quota_service.increment_success_service_use()
          return result
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetData', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetData')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetData(
  username TEXT,
  orgname TEXT,
  geomrefs TEXT[],
  params JSON)
RETURNS TABLE (
  id TEXT,
  data JSON
) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetData(geomrefs, params);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetData(
  username TEXT,
  orgname TEXT,
  geomrefs TEXT[],
  params JSON)
RETURNS TABLE (
  id TEXT,
  data JSON
) AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getdata', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetData($1, $2, $3, $4);", ["text", "text", "text[]", "json"])
        result = plpy.execute(obs_plan, [username, orgname, geomrefs, params])
        if result:
          quota_service.increment_success_service_use()
          return result
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        exc_info = sys.exc_info()
        logger.error('%s, %s, %s' % (exc_info[0], exc_info[1], exc_info[2]))
        logger.error('Error trying to OBS_GetData', exc_info, data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetData')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetMeta(
  username TEXT,
  orgname TEXT,
  geom Geometry(Geometry, 4326),
  params JSON,
  max_timespan_rank INTEGER DEFAULT NULL,
  max_score_rank INTEGER DEFAULT NULL,
  target_geoms INTEGER DEFAULT NULL)
RETURNS JSON AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetMeta(geom, params, max_timespan_rank, max_score_rank, target_geoms);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetMeta(
  username TEXT,
  orgname TEXT,
  geom Geometry(Geometry, 4326),
  params JSON,
  max_timespan_rank INTEGER DEFAULT NULL,
  max_score_rank INTEGER DEFAULT NULL,
  target_geoms INTEGER DEFAULT NULL)
RETURNS JSON AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

  with metrics('obs_getmeta', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetMeta($1, $2, $3, $4, $5, $6, $7) as meta;", ["text", "text", "Geometry (Geometry, 4326)", "json", "integer", "integer", "integer"])
        result = plpy.execute(obs_plan, [username, orgname, geom, params, max_timespan_rank, max_score_rank, target_geoms])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['meta']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetMeta', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetMeta')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;