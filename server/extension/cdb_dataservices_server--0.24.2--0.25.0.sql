--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.25.0'" to load this file. \quit

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_point(username text, orgname text, code double precision)
RETURNS Geometry AS $$
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_point(username, orgname, code::text);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_point(username text, orgname text, code double precision, country text)
RETURNS Geometry AS $$
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_point(username, orgname, code::text, country);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_polygon(username text, orgname text, code double precision)
RETURNS Geometry AS $$
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_polygon(username, orgname, code::text)
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_polygon(username text, orgname text, code double precision, country text)
RETURNS Geometry AS $$
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_polygon(username, orgname, code::text, country);
$$ LANGUAGE SQL;
