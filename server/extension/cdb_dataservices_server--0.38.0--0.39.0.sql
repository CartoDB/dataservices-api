--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.39.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade

-- In 0.39.0 we removed cdb_dataservices_client.geomval and rely on postgis_raster if necessary
DO $$
BEGIN
  DROP TYPE IF EXISTS cdb_dataservices_server.geomval RESTRICT;
END$$;
