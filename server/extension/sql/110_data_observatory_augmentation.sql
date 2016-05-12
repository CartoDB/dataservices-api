--
-- Observatory connection config
--
-- The purpose of this function is provide to the PL/Proxy functions
-- the connection string needed to connect with the current production database

CREATE OR REPLACE FUNCTION cdb_dataservices_server._obs_server_conn_str(
  username TEXT,
  orgname TEXT)
RETURNS text AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_snapshot_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_snapshot_config = GD["user_obs_snapshot_config_{0}".format(username)]

  return user_obs_snapshot_config.connection_str
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetDemographicSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL,
  geometry_level TEXT DEFAULT NULL)
RETURNS SETOF json AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetDemographicSnapshot(geom, time_span, geometry_level);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetDemographicSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL,
  geometry_level TEXT DEFAULT NULL)
RETURNS SETOF JSON AS $$
  from cartodb_services.metrics import QuotaService

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_snapshot_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_snapshot_config = GD["user_obs_snapshot_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_snapshot_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

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
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use get_geographic_snapshot: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetSegmentSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT NULL)
RETURNS SETOF json AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetSegmentSnapshot(geom, geometry_level);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetSegmentSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT NULL)
RETURNS SETOF JSON AS $$
  from cartodb_services.metrics import QuotaService

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_snapshot_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_snapshot_config = GD["user_obs_snapshot_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_snapshot_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

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
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use get_segment_snapshot: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

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

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

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
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use OBS_GetMeasure: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

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
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetCategory(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  category_id TEXT,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  from cartodb_services.metrics import QuotaService

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

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
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use OBS_GetCategory: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

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

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

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
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use OBS_GetUSCensusMeasure: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

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
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetUSCensusCategory(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  name TEXT,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL)
RETURNS TEXT AS $$
  from cartodb_services.metrics import QuotaService

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

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
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use OBS_GetUSCensusCategory: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

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

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

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
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use OBS_GetPopulation: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;
