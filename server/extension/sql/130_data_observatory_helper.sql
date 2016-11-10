CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_dumpversion(username text, orgname text)
RETURNS text AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.obs_dumpversion();
$$ LANGUAGE plproxy;

-- We could create a super type for the common data like id, name and so on but we need to parse inside the functions because the -- the return data tha comes from OBS is a TABLE() with them
CREATE TYPE cdb_dataservices_server.obs_meta_numerator AS (numer_id text, numer_name text, numer_description text, numer_weight text, numer_license text, numer_source text, numer_type text, numer_aggregate text, numer_extra jsonb, numer_tags jsonb, valid_denom boolean, valid_geom boolean, valid_timespan boolean);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableNumerators(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  filter_tags TEXT[] DEFAULT NULL,
  denom_id TEXT DEFAULT NULL,
  geom_id TEXT DEFAULT NULL,
  timespan TEXT DEFAULT NULL)
RETURNS SETOF cdb_dataservices_server.obs_meta_numerator AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableNumerators(bounds, filter_tags, denom_id, geom_id, timespan);
$$ LANGUAGE plproxy;

CREATE TYPE cdb_dataservices_server.obs_meta_denominator AS (denom_id text, denom_name text, denom_description text, denom_weight text, denom_license text, denom_source text, denom_type text, denom_aggregate text, denom_extra jsonb, denom_tags jsonb, valid_numer boolean, valid_geom boolean, valid_timespan boolean);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableDenominators(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  filter_tags TEXT[] DEFAULT NULL,
  numer_id TEXT DEFAULT NULL,
  geom_id TEXT DEFAULT NULL,
  timespan TEXT DEFAULT NULL)
RETURNS SETOF cdb_dataservices_server.obs_meta_denominator AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableDenominators(bounds, filter_tags, numer_id, geom_id, timespan);
$$ LANGUAGE plproxy;

CREATE TYPE cdb_dataservices_server.obs_meta_geometry AS (geom_id text, geom_name text, geom_description text, geom_weight text, geom_aggregate text, geom_license text, geom_source text, valid_numer boolean, valid_denom boolean, valid_timespan boolean);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableGeometries(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  filter_tags TEXT[] DEFAULT NULL,
  numer_id TEXT DEFAULT NULL,
  denom_id TEXT DEFAULT NULL,
  timespan TEXT DEFAULT NULL)
RETURNS SETOF cdb_dataservices_server.obs_meta_geometry AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableGeometries(bounds, filter_tags, numer_id, denom_id, timespan);
$$ LANGUAGE plproxy;

CREATE TYPE cdb_dataservices_server.obs_meta_timespan AS (timespan_id text, timespan_name text, timespan_description text, timespan_weight text, timespan_aggregate text, timespan_license text, timespan_source text, valid_numer boolean, valid_denom boolean, valid_geom boolean);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAvailableTimespans(
  username TEXT,
  orgname TEXT,
  bounds geometry(Geometry, 4326) DEFAULT NULL,
  filter_tags TEXT[] DEFAULT NULL,
  numer_id TEXT DEFAULT NULL,
  denom_id TEXT DEFAULT NULL,
  geom_id TEXT DEFAULT NULL)
RETURNS SETOF cdb_dataservices_server.obs_meta_timespan AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_GetAvailableTimespans(bounds, filter_tags, numer_id, denom_id, geom_id);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_LegacyBuilderMetadata(
  username TEXT,
  orgname TEXT,
  aggregate_type TEXT DEFAULT NULL)
RETURNS TABLE(name TEXT, subsection JSONB) AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT * FROM cdb_observatory.OBS_LegacyBuilderMetadata(aggregate_type);
$$ LANGUAGE plproxy;
