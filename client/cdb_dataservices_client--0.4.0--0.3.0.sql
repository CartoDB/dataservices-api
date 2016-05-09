--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.3.0'" to load this file. \quit
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_get_demographic_snapshot (text, text, geometry(Geometry, 4326), text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_get_segment_snapshot (text, text, geometry(Geometry, 4326), text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_get_demographic_snapshot (geometry(Geometry, 4326), text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_get_segment_snapshot (geometry(Geometry, 4326), text);
