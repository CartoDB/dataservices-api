--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.4.0'" to load this file. \quit
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_get_demographic_snapshot(geometry);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_get_segment_snapshot(geometry);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getdemographicsnapshot(geometry);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getsegmentsnapshot(geometry);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getboundary(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getboundaryid(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getboundarybyid(text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getboundariesbygeometry(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getboundariesbypointandradius(geometry, numeric, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getpointsbygeometry(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getpointsbypointandradius(geometry, numeric, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getmeasure(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getcategory(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getuscensusmeasure(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getuscensuscategory(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getpopulation(geometry);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_search(text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getavailableboundaries(geometry);

DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_get_demographic_snapshot(geometry);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_get_segment_snapshot(geometry);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getdemographicsnapshot(geometry);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getsegmentsnapshot(geometry);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getboundary(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getboundaryid(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getboundarybyid(text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getboundariesbygeometry(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getboundariesbypointandradius(geometry, numeric, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getpointsbygeometry(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getpointsbypointandradius(geometry, numeric, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getmeasure(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getcategory(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getuscensusmeasure(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getuscensuscategory(geometry, text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getpopulation(geometry);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_search(text);
DROP FUNCTION IF EXISTS cdb_dataservices_client.obs_getavailableboundaries(geometry);