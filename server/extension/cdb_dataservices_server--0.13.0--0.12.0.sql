--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.12.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
DROP TYPE IF EXISTS cdb_dataservices_server.ds_fdw_metadata;
DROP TYPE IF EXISTS cdb_dataservices_server.ds_return_metadata;

DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_ConnectUserTable(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_server.__OBS_ConnectUserTable(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetReturnMetadata(text, text, text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_FetchJoinFdwTableData(text, text, text, text, text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_DisconnectUserTable(text, text, text, text, text);
