--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.17.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

DROP FUNCTION cdb_dataservices_client.cdb_geocode_postalcode_polygon (postal_code double precision ,country_name text);
DROP FUNCTION cdb_dataservices_client.cdb_geocode_postalcode_point (postal_code double precision ,country_name text);
DROP FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_polygon_exception_safe (postal_code double precision ,country_name text);
DROP FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_point_exception_safe (postal_code double precision ,country_name text);
DROP FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_polygon (username text, orgname text, postal_code double precision, country_name text);
DROP FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_point (username text, orgname text, postal_code double precision, country_name text);
