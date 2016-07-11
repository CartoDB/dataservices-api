--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.7.0'" to load this file. \quit

DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_here_geocode_street_point (text, text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_google_geocode_street_point (text, text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_mapzen_geocode_street_point (text, text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_here_geocode_street_point (text, text, text, text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_google_geocode_street_point (text, text, text, text, text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapzen_geocode_street_point (text, text, text, text, text, text);
