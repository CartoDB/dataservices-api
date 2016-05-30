--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.5.0'" to load this file. \quit
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_route_with_waypoints (text, text, geometry(Point, 4326)[], text, text[], text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_route_with_waypoints (geometry(Point, 4326)[], text, text[], text);
