--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.14.1'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetMeasure(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  measure_id TEXT,
  normalize TEXT DEFAULT 'area',
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetMeasure(geom, measure_id, normalize, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetMeasure(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  measure_id TEXT,
  normalize TEXT DEFAULT 'area',
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
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
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetUSCensusMeasure(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  name TEXT,
  normalize TEXT DEFAULT 'area',
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetUSCensusMeasure(geom, name, normalize, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetUSCensusMeasure(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  name TEXT,
  normalize TEXT DEFAULT 'area',
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
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
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetPopulation(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  normalize TEXT DEFAULT 'area',
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetPopulation(geom, normalize, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetPopulation(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  normalize TEXT DEFAULT 'area',
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS NUMERIC AS $$
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
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetBoundariesByGeometry(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type text DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetBoundariesByGeometry(geom, boundary_id, time_span, overlap_type);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundariesByGeometry(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetBoundariesByPointAndRadius(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  radius NUMERIC,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetBoundariesByPointAndRadius(geom, radius, boundary_id, time_span, overlap_type);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundariesByPointAndRadius(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  radius NUMERIC,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetPointsByGeometry(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetPointsByGeometry(geom, boundary_id, time_span, overlap_type);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetPointsByGeometry(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetPointsByPointAndRadius(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  radius NUMERIC,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetPointsByPointAndRadius(geom, radius, boundary_id, time_span, overlap_type);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetPointsByPointAndRadius(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  radius NUMERIC,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL,
  overlap_type TEXT DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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
$$ LANGUAGE @@plpythonu@@;