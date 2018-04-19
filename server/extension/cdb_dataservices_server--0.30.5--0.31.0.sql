--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.31.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
ALTER TYPE cdb_dataservices_server.obs_meta_timespan ADD ATTRIBUTE timespan_alias text;
ALTER TYPE cdb_dataservices_server.obs_meta_timespan ADD ATTRIBUTE timespan_range daterange;
