--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.9.0'" to load this file. \quit
DROP FUNCTION IF EXISTS cdb_dataservices_client._OBS_GetTable(text, text, text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_client._OBS_AugmentTable(text, text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_client.__OBS_AugmentTable(text, text, text, text, text, text, text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_client.__OBS_GetTable(text, text, text, text, text, text, text, text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_client._OBS_ConnectUserTable(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._OBS_GetReturnMetadata(text, text, text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_client._OBS_FetchJoinFdwTableData(text, text, text, text, text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_client._OBS_DisconnectUserTable(text, text, text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.OBS_DumpVersion();
DROP FUNCTION IF EXISTS cdb_dataservices_client._OBS_DumpVersion(text, text);

DROP TYPE IF EXISTS cdb_dataservices_client.ds_fdw_metadata;
DROP TYPE IF EXISTS cdb_dataservices_client.ds_return_metadata;
