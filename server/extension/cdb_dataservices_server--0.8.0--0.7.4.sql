--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.7.4'" to load this file. \quit

DROP FUNCTION IF EXISTS cdb_dataservices_server._get_obs_config(text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetDemographicSnapshot(text, text, geometry(Geometry, 4326), text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetDemographicSnapshot(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetSegmentSnapshot(text, text, geometry(Geometry, 4326), text);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetSegmentSnapshot(TEXT, TEXT, geometry(Geometry, 4326), TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetMeasure(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetMeasure(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetCategory(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetCategory(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetUSCensusMeasure(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetUSCensusMeasure(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetUSCensusCategory(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetUSCensusCategory(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetPopulation(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetPopulation(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_Search(TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_Search(TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetAvailableBoundaries(TEXT, TEXT, geometry(Geometry, 4326), TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetAvailableBoundaries(TEXT, TEXT, geometry(Geometry, 4326), TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetBoundary(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetBoundary(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetBoundaryId(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetBoundaryId(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetBoundaryById(TEXT, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetBoundaryById(TEXT, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetBoundariesByGeometry(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetBoundariesByGeometry(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetBoundariesByPointAndRadius(TEXT, TEXT, NUMERIC, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetBoundariesByPointAndRadius(TEXT, TEXT, NUMERIC, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetPointsByGeometry(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetPointsByGeometry(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetPointsByPointAndRadius(TEXT, TEXT, geometry(Point, 4326), NUMERIC, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetPointsByPointAndRadius(TEXT, TEXT, geometry(Point, 4326), NUMERIC, TEXT, TEXT, TEXT);


CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetDemographicSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  time_span TEXT DEFAULT '2009 - 2013',
  geometry_level TEXT DEFAULT '"us.census.tiger".block_group')
RETURNS json AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetDemographicSnapshot(geom, time_span, geometry_level);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetSegmentSnapshot(
  username TEXT,
  orgname TEXT,
  geom geometry(Geometry, 4326),
  geometry_level TEXT DEFAULT '"us.census.tiger".block_group')
RETURNS json AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.OBS_GetSegmentSnapshot(geom, geometry_level);
$$ LANGUAGE plproxy;