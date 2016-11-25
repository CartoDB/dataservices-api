--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.18.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
ALTER TYPE cdb_dataservices_server.obs_meta_geometry DROP ATTRIBUTE score;
ALTER TYPE cdb_dataservices_server.obs_meta_geometry DROP ATTRIBUTE numtiles;
ALTER TYPE cdb_dataservices_server.obs_meta_geometry DROP ATTRIBUTE notnull_percent;
ALTER TYPE cdb_dataservices_server.obs_meta_geometry DROP ATTRIBUTE numgeoms;
ALTER TYPE cdb_dataservices_server.obs_meta_geometry DROP ATTRIBUTE percentfill;
ALTER TYPE cdb_dataservices_server.obs_meta_geometry DROP ATTRIBUTE estnumgeoms;
ALTER TYPE cdb_dataservices_server.obs_meta_geometry DROP ATTRIBUTE meanmediansize;
