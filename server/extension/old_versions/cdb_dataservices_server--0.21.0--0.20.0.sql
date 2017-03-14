--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.20.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetData(TEXT, TEXT, geomval[], JSON, BOOLEAN);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetData(TEXT, TEXT, geomval[], JSON, BOOLEAN);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetData(TEXT, TEXT, TEXT[], JSON);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetData(TEXT, TEXT, TEXT[], JSON);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetMeta(TEXT, TEXT, Geometry(Geometry, 4326), JSON, INTEGER, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetMeta(TEXT, TEXT, Geometry(Geometry, 4326), JSON, INTEGER, INTEGER, INTEGER);