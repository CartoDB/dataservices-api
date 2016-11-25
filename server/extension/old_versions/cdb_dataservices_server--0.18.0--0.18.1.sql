--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.18.1'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
ALTER TYPE cdb_dataservices_server.obs_meta_geometry ADD ATTRIBUTE score numeric;
ALTER TYPE cdb_dataservices_server.obs_meta_geometry ADD ATTRIBUTE numtiles bigint;
ALTER TYPE cdb_dataservices_server.obs_meta_geometry ADD ATTRIBUTE notnull_percent numeric;
ALTER TYPE cdb_dataservices_server.obs_meta_geometry ADD ATTRIBUTE numgeoms numeric;
ALTER TYPE cdb_dataservices_server.obs_meta_geometry ADD ATTRIBUTE percentfill numeric;
ALTER TYPE cdb_dataservices_server.obs_meta_geometry ADD ATTRIBUTE estnumgeoms numeric;
ALTER TYPE cdb_dataservices_server.obs_meta_geometry ADD ATTRIBUTE meanmediansize numeric;
