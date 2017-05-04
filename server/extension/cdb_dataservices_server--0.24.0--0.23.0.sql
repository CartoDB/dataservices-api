--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.23.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
ALTER TYPE cdb_dataservices_server.obs_meta_geometry DROP ATTRIBUTE geom_type;
ALTER TYPE cdb_dataservices_server.obs_meta_geometry DROP ATTRIBUTE geom_extra;
ALTER TYPE cdb_dataservices_server.obs_meta_geometry DROP ATTRIBUTE geom_tags;

ALTER TYPE cdb_dataservices_server.obs_meta_timespan DROP ATTRIBUTE timespan_type;
ALTER TYPE cdb_dataservices_server.obs_meta_timespan DROP ATTRIBUTE timespan_extra;
ALTER TYPE cdb_dataservices_server.obs_meta_timespan DROP ATTRIBUTE timespan_tags;
