--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.8.0'" to load this file. \quit

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
$$ LANGUAGE plpythonu SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_get_demographic_snapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL,
  geometry_level TEXT DEFAULT NULL)
RETURNS json AS $$
  obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetDemographicSnapshot($1, $2, $3, $4, $5) as snapshot;", ["text", "text", "geometry(Geometry, 4326)", "text", "text"])
  result = plpy.execute(obs_plan, [username, orgname, geom, time_span, geometry_level])
  return result
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetDemographicSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL,
  geometry_level TEXT DEFAULT NULL)
RETURNS json AS $$
  from cartodb_services.metrics import QuotaService
  import json

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
        quota_service.increment_success_service_use()
        return result[0]['snapshot']
      else:
        quota_service.increment_empty_service_use()
        return None
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

CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_get_segment_snapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT NULL)
RETURNS json AS $$
  obs_plan = plpy.prepare("SELECT cdb_dataservices_server.OBS_GetSegmentSnapshot($1, $2, $3, $4) as snapshot;", ["text", "text", "geometry(Geometry, 4326)", "text"])
  result = plpy.execute(obs_plan, [username, orgname, geom, geometry_level])
  return result
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetSegmentSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT NULL)
RETURNS json AS $$
  from cartodb_services.metrics import QuotaService
  import json

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_snapshot_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_snapshot_config = GD["user_obs_snapshot_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_snapshot_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetSegmentSnapshot($1, $2, $3, $4) as snapshot;", ["text", "text", "geometry(Geometry, 4326)", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, geometry_level])
      if result:
        quota_service.increment_success_service_use()
        return result[0]['snapshot']
      else:
        quota_service.increment_empty_service_use()
        return None
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

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_Search(
  username TEXT,
  orgname TEXT,
  search_term TEXT,
  relevant_boundary TEXT DEFAULT NULL)
RETURNS TABLE(id text, description text, name text, aggregate text, source text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_Search(search_term, relevant_boundary);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_Search(
  username TEXT,
  orgname TEXT,
  search_term TEXT,
  relevant_boundary TEXT DEFAULT NULL)
RETURNS TABLE(id text, description text, name text, aggregate text, source text) AS $$
  from cartodb_services.metrics import QuotaService

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

  try:
      obs_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._OBS_Search($1, $2, $3, $4) as search;", ["text", "text", "text", "text"])
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
        return []
  except BaseException as e:
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use OBS_Search: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetAvailableBoundaries(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL)
RETURNS TABLE(boundary_id text, description text, time_span text, tablename text) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableBoundaries(geom, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableBoundaries(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT NULL)
RETURNS TABLE(boundary_id text, description text, time_span text, tablename text) AS $$
  from cartodb_services.metrics import QuotaService

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

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
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use OBS_GetAvailableBoundaries: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

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

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

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
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use OBS_GetBoundary: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
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
  SELECT cdb_observatory.OBS_OBS_GetBoundaryId(geom, boundary_id, time_span);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetBoundaryId(
  username TEXT,
  orgname TEXT,
  geom geometry(Point, 4326),
  boundary_id TEXT,
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
      obs_plan = plpy.prepare("SELECT cdb_dataservices_server._OBS_GetBoundaryId($1, $2, $3, $4, $5) as boundary;", ["text", "text", "geometry(Point, 4326)", "text", "text"])
      result = plpy.execute(obs_plan, [username, orgname, geom, boundary_id, time_span])
      if result:
        quota_service.increment_success_service_use()
        return result[0]['boundary']
      else:
        quota_service.increment_empty_service_use()
        return None
  except BaseException as e:
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use obs_search: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
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

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

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
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use OBS_GetBoundaryById: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
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

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

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
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use OBS_GetBoundariesByGeometry: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
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

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

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
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use OBS_GetBoundariesByPointAndRadius: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
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

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

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
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use OBS_GetPointsByGeometry: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
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

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_obs_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_obs_config = GD["user_obs_config_{0}".format(username)]

  quota_service = QuotaService(user_obs_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

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
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to use OBS_GetPointsByPointAndRadius: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
  finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;


