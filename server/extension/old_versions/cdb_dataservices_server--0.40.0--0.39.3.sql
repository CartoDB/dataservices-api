--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.39.3'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade

CREATE OR REPLACE FUNCTION cdb_dataservices_server._obs_server_conn_str(
  username TEXT,
  orgname TEXT)
RETURNS text AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  return user_obs_config.connection_str
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetDemographicSnapshotJSON(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL,
  geometry_level TEXT DEFAULT NULL)
RETURNS json AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetDemographicSnapshot(geom, time_span, geometry_level);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

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
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetDemographicSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL,
  geometry_level TEXT DEFAULT NULL)
RETURNS SETOF json AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetDemographicSnapshot(geom, time_span, geometry_level);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

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
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetSegmentSnapshotJSON(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT NULL)
RETURNS json AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetSegmentSnapshot(geom, geometry_level);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

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
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

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
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetMeasure(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  measure_id TEXT,
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetMeasure(geom, measure_id, normalize, boundary_id, time_span);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetMeasure(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  measure_id TEXT,
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
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

  with metrics('obs_getmeasure', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetMeasure($1, $2, $3, $4, $5, $6, $7) as measure;", ["text", "text", "geometry(Geometry, 4326)", "text", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, measure_id, normalize, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['measure']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetMeasure', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetMeasure')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetCategory(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  category_id TEXT,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetCategory(geom, category_id, boundary_id, time_span);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetCategory(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  category_id TEXT,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
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

  with metrics('obs_getcategory', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetCategory($1, $2, $3, $4, $5, $6) as category;", ["text", "text", "geometry(Geometry, 4326)", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, category_id, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['category']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetCategory', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetCategory')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetUSCensusMeasure(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  name TEXT,
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetUSCensusMeasure(geom, name, normalize, boundary_id, time_span);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetUSCensusMeasure(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  name TEXT,
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
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

  with metrics('obs_getuscensusmeasure', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetUSCensusMeasure($1, $2, $3, $4, $5, $6, $7) as census_measure;", ["text", "text", "geometry(Geometry, 4326)", "text", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, name, normalize, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['census_measure']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetUSCensusMeasure', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetUSCensusMeasure')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetUSCensusCategory(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  name TEXT,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetUSCensusCategory(geom, name, boundary_id, time_span);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetUSCensusCategory(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  name TEXT,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
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

  with metrics('obs_getuscensuscategory', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetUSCensusCategory($1, $2, $3, $4, $5, $6) as census_category;", ["text", "text", "geometry(Geometry, 4326)", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, name, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['census_category']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetUSCensusCategory', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetUSCensusCategory')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetPopulation(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetPopulation(geom, normalize, boundary_id, time_span);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetPopulation(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
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

  with metrics('obs_getpopulation', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetPopulation($1, $2, $3, $4, $5, $6) as population;", ["text", "text", "geometry(Geometry, 4326)", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, normalize, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['population']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetPopulation', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetPopulation')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetMeasureById(
  username TEXT,
  orgname TEXT,
  geom_ref TEXT,
  measure_id TEXT,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetMeasureById(geom_ref, measure_id, boundary_id, time_span);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetMeasureById(
  username TEXT,
  orgname TEXT,
  geom_ref TEXT,
  measure_id TEXT,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
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

  with metrics('obs_getmeasurebyid', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetMeasureById($1, $2, $3, $4, $5, $6) as measure;", ["text", "text", "text", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom_ref, measure_id, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['measure']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetMeasureById', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetMeasureById')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

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
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

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

  with metrics('obs_getdata', user_obs_config, logger, params):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetData($1, $2, $3, $4, $5);", ["text", "text", "geomval[]", "json", "boolean"])
        result = plpy.execute(obs_plan, [username, orgname, geomvals, params, merge])
        empty_results = len(geomvals) - len(result)
        if empty_results > 0:
          quota_service.increment_empty_service_use(empty_results)
        if result:
          quota_service.increment_success_service_use(len(result))
          return result
        else:
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use(len(geomvals))
        logger.error('Error trying to OBS_GetData', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetData')
    finally:
        quota_service.increment_total_service_use(len(geomvals))
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

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
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

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

  with metrics('obs_getdata', user_obs_config, logger, params):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetData($1, $2, $3, $4);", ["text", "text", "text[]", "json"])
        result = plpy.execute(obs_plan, [username, orgname, geomrefs, params])
        empty_results = len(geomrefs) - len(result)
        if empty_results > 0:
          quota_service.increment_empty_service_use(empty_results)
        if result:
          quota_service.increment_success_service_use(len(result))
          return result
        else:
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use(len(geomrefs))
        exc_info = sys.exc_info()
        logger.error('%s, %s, %s' % (exc_info[0], exc_info[1], exc_info[2]))
        logger.error('Error trying to OBS_GetData', exc_info, data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetData')
    finally:
        quota_service.increment_total_service_use(len(geomrefs))
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

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
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

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
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  with metrics('obs_getmeta', user_obs_config, logger, params):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetMeta($1, $2, $3, $4, $5, $6, $7) as meta;", ["text", "text", "Geometry (Geometry, 4326)", "json", "integer", "integer", "integer"])
        result = plpy.execute(obs_plan, [username, orgname, geom, params, max_timespan_rank, max_score_rank, target_geoms])
        if result:
          return result[0]['meta']
        else:
          return None
    except BaseException as e:
        import sys
        logger.error('Error trying to OBS_GetMeta', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetMeta')
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_MetadataValidation(
  username TEXT,
  orgname TEXT,
  geometry_extent Geometry(Geometry, 4326),
  geometry_type text,
  params JSON,
  target_geoms INTEGER DEFAULT NULL)
RETURNS TABLE(valid boolean, errors text[]) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_MetadataValidation(geometry_extent, geometry_type, params, target_geoms);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_MetadataValidation(
  username TEXT,
  orgname TEXT,
  geometry_extent Geometry(Geometry, 4326),
  geometry_type text,
  params JSON,
  target_geoms INTEGER DEFAULT NULL)
RETURNS TABLE(valid boolean, errors text[]) AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  with metrics('obs_metadatavalidation', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_MetadataValidation($1, $2, $3, $4, $5, $6);", ["text", "text", "Geometry (Geometry, 4326)",  "text", "json", "integer"])
        result = plpy.execute(obs_plan, [username, orgname, geometry_extent, geometry_type, params, target_geoms])
        if result:
          return result
        else:
          return []
    except BaseException as e:
        import sys
        logger.error('Error trying to OBS_MetadataValidation', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_MetadataValidation')
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;
CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_Search(
  username TEXT,
  orgname TEXT,
  search_term TEXT,
  relevant_boundary TEXT DEFAULT NULL)
RETURNS TABLE(id text, description text, name text, aggregate text, source text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_Search(search_term, relevant_boundary);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_Search(
  username TEXT,
  orgname TEXT,
  search_term TEXT,
  relevant_boundary TEXT DEFAULT NULL)
RETURNS TABLE(id text, description text, name text, aggregate text, source text) AS $$
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

  with metrics('obs_search', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_Search($1, $2, $3, $4);", ["text", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, search_term, relevant_boundary])
        if result:
          resp = []
          for element in result:
            id = element['id']
            description = element['description']
            name = element['name']
            aggregate = element['aggregate']
            source = element['source']
            resp.append([id, description, name, aggregate, source])
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return [None, None, None, None, None]
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_Search', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_Search')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetAvailableBoundaries(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL)
RETURNS TABLE(boundary_id text, description text, time_span text, tablename text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableBoundaries(geom, time_span);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableBoundaries(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL)
RETURNS TABLE(boundary_id text, description text, time_span text, tablename text) AS $$
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

  with metrics('obs_getavailableboundaries', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetAvailableBoundaries($1, $2, $3, $4) as available_boundaries;", ["text", "text", "geometry(Geometry, 4326)", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, time_span])
        if result:
          resp = []
          for element in result:
            id = element['boundary_id']
            description = element['description']
            tspan = element['time_span']
            tablename = element['tablename']
            resp.append([id, description, tspan, tablename])
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetMeasureById', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetMeasureById')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;
CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetBoundary(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS geometry(Geometry, 4326) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetBoundary(geom, boundary_id, time_span);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundary(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS geometry(Geometry, 4326) AS $$
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

  with metrics('obs_getboundary', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetBoundary($1, $2, $3, $4) as boundary;", ["text", "text", "geometry(Point, 4326)", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['boundary']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetBoundary', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetBoundary')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetBoundaryId(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetBoundaryId(geom, boundary_id, time_span);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundaryId(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
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

  with metrics('obs_getboundaryid', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetBoundaryId($1, $2, $3, $4, $5) as boundary;", ["text", "text", "geometry(Point, 4326)", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['boundary']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetBoundaryId', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetBoundaryId')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetBoundaryById(
  username TEXT,
  orgname TEXT,
  geometry_id TEXT,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS geometry(Geometry, 4326) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetBoundaryById(geometry_id, boundary_id, time_span);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundaryById(
  username TEXT,
  orgname TEXT,
  geometry_id TEXT,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS geometry(Geometry, 4326) AS $$
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

  with metrics('obs_getboundarybyid', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetBoundaryById($1, $2, $3, $4, $5) as boundary;", ["text", "text", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geometry_id, boundary_id, time_span])
        if result:
          quota_service.increment_success_service_use()
          return result[0]['boundary']
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetBoundaryById', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetBoundaryById')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetBoundariesByGeometry(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetBoundariesByGeometry(geom, boundary_id, time_span, overlap_type);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundariesByGeometry(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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

  with metrics('obs_getboundariesbygeometry', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetBoundariesByGeometry($1, $2, $3, $4, $5, $6) as boundary;", ["text", "text", "geometry(Point, 4326)", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, boundary_id, time_span, overlap_type])
        if result:
          resp = []
          for element in result:
            the_geom = element['the_geom']
            geom_refs = element['geom_refs']
            resp.append([the_geom, geom_refs])
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetBoundariesByGeometry', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetBoundariesByGeometry')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetBoundariesByPointAndRadius(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  radius NUMERIC,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetBoundariesByPointAndRadius(geom, radius, boundary_id, time_span, overlap_type);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundariesByPointAndRadius(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  radius NUMERIC,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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

  with metrics('obs_getboundariesbypointandradius', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetBoundariesByPointAndRadius($1, $2, $3, $4, $5, $6, $7) as boundary;", ["text", "text", "geometry(Point, 4326)", "numeric", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, radius, boundary_id, time_span, overlap_type])
        if result:
          resp = []
          for element in result:
            the_geom = element['the_geom']
            geom_refs = element['geom_refs']
            resp.append([the_geom, geom_refs])
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetBoundariesByPointAndRadius', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetBoundariesByPointAndRadius')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetPointsByGeometry(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetPointsByGeometry(geom, boundary_id, time_span, overlap_type);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetPointsByGeometry(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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

  with metrics('obs_getpointsbygeometry', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetPointsByGeometry($1, $2, $3, $4, $5, $6) as boundary;", ["text", "text", "geometry(Point, 4326)", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, boundary_id, time_span, overlap_type])
        if result:
          resp = []
          for element in result:
            the_geom = element['the_geom']
            geom_refs = element['geom_refs']
            resp.append([the_geom, geom_refs])
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return []
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetPointsByGeometry', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetPointsByGeometry')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetPointsByPointAndRadius(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  radius NUMERIC,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetPointsByPointAndRadius(geom, radius, boundary_id, time_span, overlap_type);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetPointsByPointAndRadius(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  radius NUMERIC,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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

  with metrics('obs_getpointsbypointandradius', user_obs_config, logger):
    try:
        obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_GetPointsByPointAndRadius($1, $2, $3, $4, $5, $6, $7) as boundary;", ["text", "text", "geometry(Point, 4326)", "numeric", "text", "text", "text"])
        result = plpy.execute(obs_plan, [username, orgname, geom, radius, boundary_id, time_span, overlap_type])
        if result:
          resp = []
          for element in result:
            the_geom = element['the_geom']
            geom_refs = element['geom_refs']
            resp.append([the_geom, geom_refs])
          quota_service.increment_success_service_use()
          return resp
        else:
          quota_service.increment_empty_service_use()
          return None
    except BaseException as e:
        import sys
        quota_service.increment_failed_service_use()
        logger.error('Error trying to OBS_GetPointsByPointAndRadius', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to OBS_GetPointsByPointAndRadius')
    finally:
        quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE TYPE cdb_dataservices_server.ds_fdw_metadata as (schemaname text, tabname text, servername text);

CREATE TYPE cdb_dataservices_server.ds_return_metadata as (colnames text[], coltypes text[]);

CREATE OR REPLACE FUNCTION cdb_dataservices_server._DST_ConnectUserTable(username text, orgname text, user_db_role text, input_schema text, dbname text, table_name text)
RETURNS cdb_dataservices_server.ds_fdw_metadata AS $$
    host_addr = plpy.execute("SELECT split_part(inet_client_addr()::text, '/', 1) as user_host")[0]['user_host']
    return plpy.execute("SELECT * FROM cdb_dataservices_server.__DST_ConnectUserTable({username}::text, {orgname}::text, {user_db_role}::text, {schema}::text, {dbname}::text, {host_addr}::text, {table_name}::text)"
        .format(username=plpy.quote_nullable(username), orgname=plpy.quote_nullable(orgname), user_db_role=plpy.quote_literal(user_db_role), schema=plpy.quote_literal(input_schema), dbname=plpy.quote_literal(dbname), table_name=plpy.quote_literal(table_name), host_addr=plpy.quote_literal(host_addr))
        )[0]
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.__DST_ConnectUserTable(username text, orgname text, user_db_role text, input_schema text, dbname text, host_addr text, table_name text)
RETURNS cdb_dataservices_server.ds_fdw_metadata AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_ConnectUserTable;
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._DST_GetReturnMetadata(username text, orgname text, function_name text, params json)
RETURNS cdb_dataservices_server.ds_return_metadata AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_GetReturnMetadata;
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._DST_FetchJoinFdwTableData(username text, orgname text, table_schema text, table_name text, function_name text, params json)
RETURNS SETOF record AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_FetchJoinFdwTableData;
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;


CREATE OR REPLACE FUNCTION cdb_dataservices_server._DST_DisconnectUserTable(username text, orgname text, table_schema text, table_name text, servername text)
RETURNS boolean AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_DisconnectUserTable;
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_dumpversion(username text, orgname text)
RETURNS text AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.obs_dumpversion();
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

-- We could create a super type for the common data like id, name and so on but we need to parse inside the functions because the -- the return data tha comes from OBS is a TABLE() with them
CREATE TYPE cdb_dataservices_server.obs_meta_numerator AS (numer_id text, numer_name text, numer_description text, numer_weight text, numer_license text, numer_source text, numer_type text, numer_aggregate text, numer_extra jsonb, numer_tags jsonb, valid_denom boolean, valid_geom boolean, valid_timespan boolean);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableNumerators(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  filter_tags TEXT[] DEFAULT NULL,
  denom_id TEXT DEFAULT NULL,
  geom_id TEXT DEFAULT NULL,
  timespan TEXT DEFAULT NULL)
RETURNS SETOF cdb_dataservices_server.obs_meta_numerator AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableNumerators(bounds, filter_tags, denom_id, geom_id, timespan);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetNumerators(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  section_tags TEXT[] DEFAULT ARRAY[]::TEXT[],
  subsection_tags TEXT[] DEFAULT ARRAY[]::TEXT[],
  other_tags TEXT[] DEFAULT ARRAY[]::TEXT[],
  ids TEXT[] DEFAULT ARRAY[]::TEXT[],
  name TEXT DEFAULT NULL,
  denom_id TEXT DEFAULT '',
  geom_id TEXT DEFAULT '',
  timespan TEXT DEFAULT '')
RETURNS SETOF cdb_dataservices_server.obs_meta_numerator AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory._OBS_GetNumerators(bounds, section_tags, subsection_tags, other_tags, ids, name, denom_id, geom_id, timespan);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE TYPE cdb_dataservices_server.obs_meta_denominator AS (denom_id text, denom_name text, denom_description text, denom_weight text, denom_license text, denom_source text, denom_type text, denom_aggregate text, denom_extra jsonb, denom_tags jsonb, valid_numer boolean, valid_geom boolean, valid_timespan boolean);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableDenominators(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  filter_tags TEXT[] DEFAULT NULL,
  numer_id TEXT DEFAULT NULL,
  geom_id TEXT DEFAULT NULL,
  timespan TEXT DEFAULT NULL)
RETURNS SETOF cdb_dataservices_server.obs_meta_denominator AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableDenominators(bounds, filter_tags, numer_id, geom_id, timespan);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE TYPE cdb_dataservices_server.obs_meta_geometry AS (geom_id text, geom_name text, geom_description text, geom_weight text, geom_aggregate text, geom_license text, geom_source text, valid_numer boolean, valid_denom boolean, valid_timespan boolean, score numeric, numtiles bigint, notnull_percent numeric, numgeoms numeric, percentfill numeric, estnumgeoms numeric, meanmediansize numeric, geom_type text, geom_extra jsonb, geom_tags jsonb);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableGeometries(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  filter_tags TEXT[] DEFAULT NULL,
  numer_id TEXT DEFAULT NULL,
  denom_id TEXT DEFAULT NULL,
  timespan TEXT DEFAULT NULL,
  number_geometries INTEGER DEFAULT NULL)
RETURNS SETOF cdb_dataservices_server.obs_meta_geometry AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableGeometries(bounds, filter_tags, numer_id, denom_id, timespan, number_geometries);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE TYPE cdb_dataservices_server.obs_meta_timespan AS (timespan_id text, timespan_name text, timespan_description text, timespan_weight text, timespan_aggregate text, timespan_license text, timespan_source text, valid_numer boolean, valid_denom boolean, valid_geom boolean, timespan_type text, timespan_extra jsonb, timespan_tags jsonb);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableTimespans(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  filter_tags TEXT[] DEFAULT NULL,
  numer_id TEXT DEFAULT NULL,
  denom_id TEXT DEFAULT NULL,
  geom_id TEXT DEFAULT NULL)
RETURNS SETOF cdb_dataservices_server.obs_meta_timespan AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableTimespans(bounds, filter_tags, numer_id, denom_id, geom_id);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_LegacyBuilderMetadata(
  username TEXT,
  orgname TEXT,
  aggregate_type TEXT DEFAULT NULL)
RETURNS TABLE(name TEXT, subsection JSON) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_LegacyBuilderMetadata(aggregate_type);
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_obs_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_obs_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import ObservatoryConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    obs_config = ObservatoryConfig(redis_conn, plpy, username, orgname)
    GD[cache_key] = obs_config
    return True
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;

WITH c AS (
  SELECT pg_type.oid as id
  FROM pg_type INNER JOIN pg_namespace ON (pg_type.typnamespace = pg_namespace.oid)
  WHERE pg_type.typname = 'service_type' AND pg_namespace.nspname = 'cdb_dataservices_server'
)
INSERT INTO pg_enum (enumtypid, enumsortorder, enumlabel)
SELECT c.id, 4, 'observatory' FROM c;

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
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;
