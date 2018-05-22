--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.31.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_bulk_google_geocode_street_point(username TEXT, orgname TEXT, searchtext jsonb);
DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_bulk_geocode_street_point(username TEXT, orgname TEXT, searchtext jsonb);
DROP TYPE IF EXISTS cdb_dataservices_server.geocoding;
