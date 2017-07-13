--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.17.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

ALTER TYPE cdb_dataservices_client.obs_meta_geometry ADD ATTRIBUTE geom_type text;
ALTER TYPE cdb_dataservices_client.obs_meta_geometry ADD ATTRIBUTE geom_extra jsonb;
ALTER TYPE cdb_dataservices_client.obs_meta_geometry ADD ATTRIBUTE geom_tags jsonb;

ALTER TYPE cdb_dataservices_client.obs_meta_timespan ADD ATTRIBUTE timespan_type text;
ALTER TYPE cdb_dataservices_client.obs_meta_timespan ADD ATTRIBUTE timespan_extra jsonb;
ALTER TYPE cdb_dataservices_client.obs_meta_timespan ADD ATTRIBUTE timespan_tags jsonb;
