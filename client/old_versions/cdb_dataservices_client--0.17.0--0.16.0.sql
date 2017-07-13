--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.16.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

ALTER TYPE cdb_dataservices_client.obs_meta_geometry DROP ATTRIBUTE geom_type;
ALTER TYPE cdb_dataservices_client.obs_meta_geometry DROP ATTRIBUTE geom_extra;
ALTER TYPE cdb_dataservices_client.obs_meta_geometry DROP ATTRIBUTE geom_tags;

ALTER TYPE cdb_dataservices_client.obs_meta_timespan DROP ATTRIBUTE timespan_type;
ALTER TYPE cdb_dataservices_client.obs_meta_timespan DROP ATTRIBUTE timespan_extra;
ALTER TYPE cdb_dataservices_client.obs_meta_timespan DROP ATTRIBUTE timespan_tags;
