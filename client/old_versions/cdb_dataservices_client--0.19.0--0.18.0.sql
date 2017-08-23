--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.18.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade
DROP IF EXISTS FUNCTION cdb_dataservices_client._obs_getnumerators (geometry(Geometry, 4326), text[], text[] , text[], text[] , text, text, text,text);
DROP IF EXISTS FUNCTION cdb_dataservices_client.__obs_getnumerators_exception_safe (geometry(Geometry, 4326), text[], text[] , text[], text[] , text, text, text,text);
DROP IF EXISTS FUNCTION cdb_dataservices_client.__obs_getnumerators (text, text, geometry(Geometry, 4326), text[], text[] , text[], text[] , text, text, text,text);
