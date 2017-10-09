--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.19.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade
DROP FUNCTION IF EXISTS _OBS_PreCheck(text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_metadatavalidation (Geometry(Geometry, 4326), text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_metadatavalidation_exception_safe (Geometry(Geometry, 4326), text, json);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_metadatavalidation (text, text, Geometry(Geometry, 4326), text, json);
