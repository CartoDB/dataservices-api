--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.27.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
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
$$ LANGUAGE plproxy;

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
$$ LANGUAGE plpythonu;
