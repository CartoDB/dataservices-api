--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.30.5'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
ALTER TYPE cdb_dataservices_server.obs_meta_timespan DROP ATTRIBUTE timespan_range;
ALTER TYPE cdb_dataservices_server.obs_meta_timespan DROP ATTRIBUTE timespan_alias;
