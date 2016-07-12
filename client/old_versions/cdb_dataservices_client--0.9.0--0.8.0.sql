--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.8.0'" to load this file. \quit
DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_mapzen_isochrone(geometry(Geometry, 4326), text, integer[], text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_mapzen_isodistance(geometry(Geometry, 4326), text, integer[], text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapzen_isochrone(text, text, geometry(Geometry, 4326), text, integer[], text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapzen_isodistance(text, text, geometry(Geometry, 4326), text, integer[], text[]);
