--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.25.0'" to load this file. \quit

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetNumerators(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  section_tags TEXT[] DEFAULT ARRAY[]::TEXT[],
  subsection_tags TEXT[] DEFAULT ARRAY[]::TEXT[],
  other_tags TEXT[] DEFAULT ARRAY[]::TEXT[],
  ids TEXT[] DEFAULT ARRAY[]::TEXT[],
  name TEXT DEFAULT NULL,
  denom_id TEXT DEFAULT '',
  geom_id TEXT DEFAULT '',
  timespan TEXT DEFAULT '')
RETURNS SETOF cdb_dataservices_server.obs_meta_numerator AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory._OBS_GetNumerators(bounds, section_tags, subsection_tags, other_tags, ids, name, denom_id, geom_id, timespan);
$$ LANGUAGE plproxy;
