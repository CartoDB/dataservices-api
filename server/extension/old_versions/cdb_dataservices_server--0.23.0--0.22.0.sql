--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.22.0'" to load this file. \quit

DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_service_get_rate_limit(TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_service_set_user_rate_limit(TEXT, TEXT, TEXT, JSON);
DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_service_set_org_rate_limit(TEXT, TEXT, TEXT, JSON);
DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_service_set_server_rate_limit(TEXT, TEXT, TEXT, JSON);

DROP FUNCTION IF EXISTS cdb_dataservices_server.CDB_Conf_SetConf(text, JSON);
DROP FUNCTION IF EXISTS cdb_dataservices_server.CDB_Conf_RemoveConf(text);

DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_here_geocode_street_point(TEXT, TEXT, TEXT, TEXT,  TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_google_geocode_street_point(TEXT, TEXT, TEXT, TEXT,  TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_mapzen_geocode_street_point(TEXT, TEXT, TEXT, TEXT,  TEXT, TEXT);
