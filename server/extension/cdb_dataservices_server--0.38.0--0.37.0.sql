--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.37.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
-- PG12_DEPRECATED
-- Create geomval if it doesn't exist (in postgis 3+ it only exists in postgis_raster)
DO $$
BEGIN
  DROP TYPE IF EXISTS cdb_dataservices_server.geomval RESTRICT;
END$$;

---- cdb_geocode_namedplace_point(city_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text)
RETURNS Geometry AS $$
  import spiexceptions
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  try:
    street_point = plpy.prepare("SELECT cdb_dataservices_server.cdb_geocode_street_point($1, $2, $3) as point;", ["text", "text", "text"])
    return plpy.execute(street_point, [username, orgname, city_name])[0]['point']
  except spiexceptions.ExternalRoutineException as e:
    import sys
    logger.error('Error geocoding namedplace using geocode street point, falling back to internal geocoder', sys.exc_info(), data={"username": username, "orgname": orgname})
    internal_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_internal_geocode_namedplace($1, $2, $3) as point;", ["text", "text", "text"])
    return plpy.execute(internal_plan, [username, orgname, city_name])[0]['point']
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

---- cdb_geocode_namedplace_point(city_name text, country_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text, country_name text)
RETURNS Geometry AS $$
  import spiexceptions
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  try:
    street_point = plpy.prepare("SELECT cdb_dataservices_server.cdb_geocode_street_point($1, $2, $3, NULL, NULL, $4) as point;", ["text", "text", "text", "text"])
    return plpy.execute(street_point, [username, orgname, city_name, country_name])[0]['point']
  except spiexceptions.ExternalRoutineException as e:
    import sys
    logger.error('Error geocoding namedplace using geocode street point, falling back to internal geocoder', sys.exc_info(), data={"username": username, "orgname": orgname})
    internal_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_internal_geocode_namedplace($1, $2, $3, NULL, $4) as point;", ["text", "text", "text", "text"])
    return plpy.execute(internal_plan, [username, orgname, city_name, country_name])[0]['point']
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

---- cdb_geocode_namedplace_point(city_name text, admin1_name text, country_name text)
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text, admin1_name text, country_name text)
RETURNS Geometry AS $$
  import spiexceptions
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  try:
    street_point = plpy.prepare("SELECT cdb_dataservices_server.cdb_geocode_street_point($1, $2, $3, NULL, $4, $5) as point;", ["text", "text", "text", "text", "text"])
    return plpy.execute(street_point, [username, orgname, city_name, admin1_name, country_name])[0]['point']
  except spiexceptions.ExternalRoutineException as e:
    import sys
    logger.error('Error geocoding namedplace using geocode street point, falling back to internal geocoder', sys.exc_info(), data={"username": username, "orgname": orgname})
    internal_plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_internal_geocode_namedplace($1, $2, $3, $4, $5) as point;", ["text", "text", "text", "text", "text"])
    return plpy.execute(internal_plan, [username, orgname, city_name, admin1_name, country_name])[0]['point']
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;