-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.28.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade

DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_mapbox_iso_isochrone;

DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_mapbox_iso_isodistance;

DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapbox_iso_isochrone_exception_safe;

DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapbox_iso_isodistance_exception_safe;

DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapbox_iso_isochrone;

DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapbox_iso_isodistance;
