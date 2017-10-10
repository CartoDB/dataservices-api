--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.28.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableGeometries(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  filter_tags TEXT[] DEFAULT NULL,
  numer_id TEXT DEFAULT NULL,
  denom_id TEXT DEFAULT NULL,
  timespan TEXT DEFAULT NULL,
  number_geometries INTEGER DEFAULT NULL)
RETURNS SETOF cdb_dataservices_server.obs_meta_geometry AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableGeometries(bounds, filter_tags, numer_id, denom_id, timespan, number_geometries);
$$ LANGUAGE plproxy;
DROP FUNCTION cdb_dataservices_server.OBS_GetAvailableGeometries(TEXT, TEXT, geometry(Geometry, 4326), TEXT[], TEXT, TEXT, TEXT);
