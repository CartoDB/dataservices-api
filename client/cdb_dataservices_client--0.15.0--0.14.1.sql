--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.14.1'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getdata (text, text, geomval[], json, boolean);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getdata (text, text, text[], json);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getmeta (text, text, Geometry(Geometry, 4326), json, integer, integer, integer);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getdata_exception_safe (geomval[], json, boolean);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getdata_exception_safe (text[], json);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getmeta_exception_safe (Geometry(Geometry, 4326), json , integer, integer, integer);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getdata (geomval[], json, boolean);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getdata (text[], json);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getmeta (Geometry(Geometry, 4326), json, integer, integer, integer);
