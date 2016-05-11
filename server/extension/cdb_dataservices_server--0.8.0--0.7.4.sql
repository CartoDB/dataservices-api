--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.7.4'" to load this file. \quit

DROP FUNCTION IF EXISTS cdb_dataservices_server._get_obs_config(text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetDemographicSnapshot(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetSegmentSnapshot(TEXT, TEXT, geometry(Geometry, 4326), TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetMeasure(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetMeasure(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetCategory(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetCategory(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetUSCensusMeasure(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetUSCensusMeasure(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetUSCensusCategory(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetUSCensusCategory(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetPopulation(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetPopulation(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_Search(TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_Search(TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetAvailableBoundaries(TEXT, TEXT, geometry(Geometry, 4326), TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetAvailableBoundaries(TEXT, TEXT, geometry(Geometry, 4326), TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetBoundary(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetBoundary(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetBoundaryId(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetBoundaryId(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetBoundaryById(TEXT, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetBoundaryById(TEXT, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetBoundariesByGeometry(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetBoundariesByGeometry(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetBoundariesByPointAndRadius(TEXT, TEXT, NUMERIC, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetBoundariesByPointAndRadius(TEXT, TEXT, NUMERIC, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetPointsByGeometry(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetPointsByGeometry(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetPointsByPointAndRadius(TEXT, TEXT, geometry(Point, 4326), NUMERIC, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetPointsByPointAndRadius(TEXT, TEXT, geometry(Point, 4326), NUMERIC, TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_get_demographic_snapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT '2009 - 2013',
  geometry_level TEXT DEFAULT '"us.census.tiger".block_group')
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
  geometry_level TEXT DEFAULT '"us.census.tiger".block_group')
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