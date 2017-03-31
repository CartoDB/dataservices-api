--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.15.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_service_get_rate_limit (text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_service_set_user_rate_limit (text, text, text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_service_set_org_rate_limit (text, text, text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_service_set_server_rate_limit (text, text, text, json);

DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_get_rate_limit_exception_safe (text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_set_user_rate_limit_exception_safe (text, text, text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_set_org_rate_limit_exception_safe (text, text, text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_set_server_rate_limit_exception_safe (text, text, text, json);

DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_get_rate_limit (text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_set_user_rate_limit (text, text, text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_set_org_rate_limit (text, text, text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_set_server_rate_limit (text, text, text, json);
