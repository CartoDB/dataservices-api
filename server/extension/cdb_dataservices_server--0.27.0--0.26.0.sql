--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.26.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_MetadataValidation(TEXT, TEXT, Geometry(Geometry, 4326), text, JSON, INTEGER);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_MetadataValidation(Geometry(Geometry, 4326), text, JSON, INTEGER);
