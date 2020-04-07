--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.28.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade
-- PG12_DEPRECATED
-- Create geomval if it doesn't exist (in postgis 3+ it only exists in postgis_raster)
DO $$
BEGIN
  DROP TYPE IF EXISTS cdb_dataservices_client.geomval RESTRICT;
END$$;