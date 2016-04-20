CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_do_get_demographic_snapshot(
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
  plpy.execute("SELECT cdb_dataservices_server._get_data_observatory_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_data_observatory_config = GD["user_data_observatory_config_{0}".format(username)]

  quota_service = QuotaService(user_data_observatory_config, redis_conn)

  try:
      obs_plan = plpy.prepare("SELECT cdb_observatory.OBS_GetDemographicSnapshot($1, $2, $3) as snapshot;", ["geometry(Geometry, 4326)", "text", "text"])
      result = plpy.execute(obs_plan, [geom, time_span, geometry_level])
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

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_do_get_segment_snapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT '"us.census.tiger".block_group')
RETURNS json AS $$
  from cartodb_services.metrics import QuotaService
  import json

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_data_observatory_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_data_observatory_config = GD["user_data_observatory_config_{0}".format(username)]

  quota_service = QuotaService(user_data_observatory_config, redis_conn)

  try:
      obs_plan = plpy.prepare("SELECT cdb_observatory.OBS_GetSegmentSnapshot($1, $2, $3) as snapshot;", ["geometry(Geometry, 4326)", "text"])
      result = plpy.execute(obs_plan, [geom, geometry_level])
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