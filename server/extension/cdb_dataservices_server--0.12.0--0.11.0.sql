--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.11.0'" to load this file. \quit

DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_mapzen_isolines(text, text, text, geometry(Geometry, 4326), text, integer[], text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_mapzen_isodistance(TEXT, TEXT, geometry(Geometry, 4326), TEXT, integer[], text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_mapzen_isochrone(TEXT, TEXT, geometry(Geometry, 4326), TEXT, integer[], text[]);
