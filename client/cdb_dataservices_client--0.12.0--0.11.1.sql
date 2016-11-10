--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.11.1'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getavailablenumerators (geometry(Geometry, 4326), text[], text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getavailabledenominators (geometry(Geometry, 4326), text[], text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getavailablegeometries (geometry(Geometry, 4326), text[], text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getavailabletimespans (geometry(Geometry, 4326), text[], text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_legacybuildermetadata(text);

DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getavailablenumerators (text, text, geometry(Geometry, 4326), text[], text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getavailabledenominators (text, text, geometry(Geometry, 4326), text[], text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getavailablegeometries (text, text, geometry(Geometry, 4326), text[], text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getavailabletimespans (text, text, geometry(Geometry, 4326), text[], text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_legacybuildermetadata(text);

DROP TYPE IF EXISTS cdb_dataservices_client.obs_meta_numerator;
DROP TYPE IF EXISTS cdb_dataservices_client.obs_meta_denominator;
DROP TYPE IF EXISTS cdb_dataservices_client.obs_meta_geometry;
DROP TYPE IF EXISTS cdb_dataservices_client.obs_meta_timespan;
