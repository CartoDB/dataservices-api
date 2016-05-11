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
