--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.22.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade

DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_mapbox_geocode_street_point (searchtext text, city text, state_province text, country text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_mapbox_isochrone (source geometry(Geometry, 4326), mode text, range integer[], options text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_mapbox_isodistance (source geometry(Geometry, 4326), mode text, range integer[], options text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapbox_geocode_street_point_exception_safe (searchtext text, city text, state_province text, country text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapbox_isochrone_exception_safe(source geometry(Geometry, 4326), mode text, range integer[], options text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapbox_isodistance_exception_safe(source geometry(Geometry, 4326), mode text, range integer[], options text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapbox_geocode_street_point (username text, orgname text, searchtext text, city text, state_province text, country text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapbox_isochrone (username text, orgname text, source geometry(Geometry, 4326), mode text, range integer[], options text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapbox_isodistance (username text, orgname text, source geometry(Geometry, 4326), mode text, range integer[], options text[]);
