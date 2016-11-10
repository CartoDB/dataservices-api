--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.17.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
DROP FUNCTION IF EXISTS cdb_dataservices_server.obs_getavailablenumerators(TEXT, TEXT, geometry(Geometry, 4326), TEXT[], TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.obs_getavailabledenominators(TEXT, TEXT, geometry(Geometry, 4326), TEXT[], TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.obs_getavailablegeometries(TEXT, TEXT, geometry(Geometry, 4326), TEXT[], TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.obs_getavailabletimespans(TEXT, TEXT, geometry(Geometry, 4326), TEXT[], TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.obs_legacybuildermetadata(TEXT);

DROP TYPE IF EXISTS cdb_dataservices_server.obs_meta_numerator;
DROP TYPE IF EXISTS cdb_dataservices_server.obs_meta_denominator;
DROP TYPE IF EXISTS cdb_dataservices_server.obs_meta_geometry;
DROP TYPE IF EXISTS cdb_dataservices_server.obs_meta_timespan;
