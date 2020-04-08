--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.30.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade

-- In 0.30.0 we removed cdb_dataservices_client.geomval and rely on postgis_raster if necessary
DO $$
BEGIN
  DROP TYPE IF EXISTS cdb_dataservices_client.geomval RESTRICT;
END$$;
