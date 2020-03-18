--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.33.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
DROP FUNCTION IF EXISTS cdb_dataservices_server._get_obs_snapshot_config;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._obs_server_conn_str(
  username TEXT,
  orgname TEXT)
RETURNS text AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  return user_obs_config.connection_str
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_get_demographic_snapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL,
  geometry_level TEXT DEFAULT NULL)
RETURNS json AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig
  import json

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

  with metrics('obs_getdemographicsnapshot', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetDemographicSnapshotJSON($1, $2, $3, $4, $5) as snapshot;", ["text", "text", "geometry(Geometry, 4326)", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, time_span, geometry_level])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['snapshot']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to obs_get_demographic_snapshot', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to obs_get_demographic_snapshot')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetDemographicSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL,
  geometry_level TEXT DEFAULT NULL)
RETURNS SETOF JSON AS $$
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

  with metrics('obs_getdemographicsnapshot', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetDemographicSnapshot($1, $2, $3, $4, $5) as snapshot;", ["text", "text", "geometry(Geometry, 4326)", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, time_span, geometry_level])
        if result:
          resp = []
          for element in result:
            value = element['snapshot']
            resp.append(value)
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to obs_get_demographic_snapshot', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to obs_get_demographic_snapshot')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_get_segment_snapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT NULL)
RETURNS json AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger,LoggerConfig
  import json

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

  with metrics('obs_getsegmentsnapshot', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetSegmentSnapshotJSON($1, $2, $3, $4) as snapshot;", ["text", "text", "geometry(Geometry, 4326)", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, geometry_level])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['snapshot']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to obs_get_segment_snapshot', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to obs_get_segment_snapshot')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetSegmentSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT NULL)
RETURNS SETOF json AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetSegmentSnapshot(geom, geometry_level);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetSegmentSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT NULL)
RETURNS SETOF JSON AS $$
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

  with metrics('obs_getsegmentsnapshot', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetSegmentSnapshot($1, $2, $3, $4) as snapshot;", ["text", "text", "geometry(Geometry, 4326)", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, geometry_level])
        if result:
          resp = []
          for element in result:
            value = element['snapshot']
            resp.append(value)
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetSegmentSnapshot', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetSegmentSnapshot')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;
