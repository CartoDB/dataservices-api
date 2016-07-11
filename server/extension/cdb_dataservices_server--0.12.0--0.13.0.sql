--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.13.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
CREATE TYPE cdb_dataservices_server.ds_fdw_metadata as (schemaname text, tabname text, servername text);

CREATE TYPE cdb_dataservices_server.ds_return_metadata as (colnames text[], coltypes text[]);

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_ConnectUserTable(username text, orgname text, user_db_role text, input_schema text, dbname text, table_name text)
RETURNS cdb_dataservices_server.ds_fdw_metadata AS $$
    return plpy.execute("SELECT * FROM cdb_dataservices_server.__OBS_ConnectUserTable({username}::text, {orgname}::text, {user_db_role}::text, {schema}::text, {dbname}::text, {table_name}::text)"
        .format(username=plpy.quote_nullable(username), orgname=plpy.quote_nullable(orgname), user_db_role=plpy.quote_literal(user_db_role), schema=plpy.quote_literal(input_schema), dbname=plpy.quote_literal(dbname), table_name=plpy.quote_literal(table_name))
        )[0]
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.__OBS_ConnectUserTable(username text, orgname text, user_db_role text, input_schema text, dbname text, table_name text)
RETURNS cdb_dataservices_server.ds_fdw_metadata AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_ConnectUserTable;
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetReturnMetadata(username text, orgname text, function_name text, params json)
RETURNS cdb_dataservices_server.ds_return_metadata AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_GetReturnMetadata;
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_FetchJoinFdwTableData(username text, orgname text, table_schema text, table_name text, function_name text, params json)
RETURNS SETOF record AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_FetchJoinFdwTableData;
$$ LANGUAGE plproxy;


CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_DisconnectUserTable(username text, orgname text, table_schema text, table_name text, servername text)
RETURNS boolean AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_DisconnectUserTable;
$$ LANGUAGE plproxy;


CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapzen_isolines(
   username TEXT,
   orgname TEXT,
   isotype TEXT,
   source geometry(Geometry, 4326),
   mode TEXT,
   data_range integer[],
   options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  import json
  from cartodb_services.mapzen import MatrixClient
  from cartodb_services.mapzen import MapzenIsolines
  from cartodb_services.metrics import QuotaService

  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  user_mapzen_isolines_routing_config = GD["user_mapzen_isolines_routing_config_{0}".format(username)]

  # -- Check the quota
  quota_service = QuotaService(user_mapzen_isolines_routing_config, redis_conn)
  if not quota_service.check_user_quota():
    plpy.error('You have reached the limit of your quota')

  try:
    client = MatrixClient(user_mapzen_isolines_routing_config.mapzen_matrix_api_key)
    mapzen_isolines = MapzenIsolines(client)

    if source:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
      origin = {'lat': lat, 'lon': lon}
    else:
      raise Exception('source is NULL')

    # -- TODO Support options properly
    isolines = {}
    if isotype == 'isodistance':
      for r in data_range:
          isoline = mapzen_isolines.calculate_isodistance(origin, mode, r)
          isolines[r] = isoline
    elif isotype == 'isochrone':
      for r in data_range:
          isoline = mapzen_isolines.calculate_isochrone(origin, mode, r)
          isolines[r] = isoline

    result = []
    for r in data_range:

      if len(isolines[r]) >= 3:
        # -- TODO encapsulate this block into a func/method
        locations = isolines[r] + [ isolines[r][0] ] # close the polygon repeating the first point
        wkt_coordinates = ','.join(["%f %f" % (l['lon'], l['lat']) for l in locations])
        sql = "SELECT ST_MPolyFromText('MULTIPOLYGON((({0})))', 4326) as geom".format(wkt_coordinates)
        multipolygon = plpy.execute(sql, 1)[0]['geom']
      else:
        multipolygon = None

      result.append([source, r, multipolygon])

    quota_service.increment_success_service_use()
    quota_service.increment_isolines_service_use(len(isolines))
    return result
  except BaseException as e:
    import sys, traceback
    type_, value_, traceback_ = sys.exc_info()
    quota_service.increment_failed_service_use()
    error_msg = 'There was an error trying to obtain isolines using mapzen: {0}'.format(e)
    plpy.debug(traceback.format_tb(traceback_))
    raise e
    #plpy.error(error_msg)
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu SECURITY DEFINER;


CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapzen_isodistance(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_mapzen_isolines_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_mapzen_isolines_routing_config_{0}".format(username)]
  type = 'isodistance'

  mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_isolines($1, $2, $3, $4, $5, $6, $7) as isoline; ", ["text", "text", "text", "geometry(Geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(mapzen_plan, [username, orgname, type, source, mode, range, options])

  return result
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_mapzen_isochrone(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_mapzen_isolines_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_mapzen_isolines_routing_config_{0}".format(username)]
  type = 'isochrone'

  mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server._cdb_mapzen_isolines($1, $2, $3, $4, $5, $6, $7) as isoline; ", ["text", "text", "text", "geometry(Geometry, 4326)", "text", "integer[]", "text[]"])
  result = plpy.execute(mapzen_plan, [username, orgname, type, source, mode, range, options])

  return result
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_dumpversion(username text, orgname text)
RETURNS text AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.obs_dumpversion();
$$ LANGUAGE plproxy;
