--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.24.2'" to load this file. \quit

DROP FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_point(username text, orgname text, code double precision);
DROP FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_point(username text, orgname text, code double precision, country text);
DROP FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_polygon(username text, orgname text, code double precision);
DROP FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_polygon(username text, orgname text, code double precision, country text);
