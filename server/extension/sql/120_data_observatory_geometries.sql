CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetBoundary(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS geometry(Geometry, 4326) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetBoundary(geom, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundary(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS geometry(Geometry, 4326) AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  logger = Logger(user_obs_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

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
      logger.error('Error trying to OBS_GetBoundary', sys.exc_info())
      raise e
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetBoundaryId(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetBoundaryId(geom, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundaryId(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  logger = Logger(user_obs_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

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
      logger.error('Error trying to OBS_GetBoundaryId', sys.exc_info())
      raise e
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetBoundaryById(
  username TEXT,
  orgname TEXT,
  geometry_id TEXT,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS geometry(Geometry, 4326) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetBoundaryById(geometry_id, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundaryById(
  username TEXT,
  orgname TEXT,
  geometry_id TEXT,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL)
RETURNS geometry(Geometry, 4326) AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  logger = Logger(user_obs_config)
  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    raise Exception('You have reached the limit of your quota')

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
      logger.error('Error trying to OBS_GetBoundaryById', sys.exc_info())
      raise e
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

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
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  logger = Logger(user_obs_config)
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
      logger.error('Error trying to OBS_GetBoundariesByGeometry', sys.exc_info())
      raise e
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

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
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  logger = Logger(user_obs_config)
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
      logger.error('Error trying to OBS_GetBoundariesByPointAndRadius', sys.exc_info())
      raise e
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

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
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  logger = Logger(user_obs_config)
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
      logger.error('Error trying to OBS_GetPointsByGeometry', sys.exc_info())
      raise e
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

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
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  logger = Logger(user_obs_config)
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
      logger.error('Error trying to OBS_GetPointsByPointAndRadius', sys.exc_info())
      raise e
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;
