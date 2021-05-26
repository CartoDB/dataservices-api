--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.40.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade

DROP FUNCTION IF EXISTS cdb_dataservices_server._obs_server_conn_str(TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.obs_get_demographic_snapshot(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetDemographicSnapshotJSON(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetDemographicSnapshot(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetDemographicSnapshot(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.obs_get_segment_snapshot(TEXT, TEXT, geometry(Geometry, 4326), TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetSegmentSnapshotJSON(TEXT, TEXT, geometry(Geometry, 4326), TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetSegmentSnapshot(TEXT, TEXT, geometry(Geometry, 4326), TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetSegmentSnapshot(TEXT, TEXT, geometry(Geometry, 4326), TEXT);
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
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetMeasureById(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetMeasureById(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetData(TEXT, TEXT, geomval[], JSON, BOOLEAN);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetData(TEXT, TEXT, geomval[], JSON, BOOLEAN);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetData(TEXT, TEXT, TEXT[], JSON);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetData(TEXT, TEXT, TEXT[], JSON);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetMeta(TEXT, TEXT, geometry(Geometry, 4326), JSON, INTEGER, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetMeta(TEXT, TEXT, geometry(Geometry, 4326), JSON, INTEGER, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_MetadataValidation(TEXT, TEXT, geometry(Geometry, 4326), TEXT, JSON, INTEGER);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_MetadataValidation(TEXT, TEXT, geometry(Geometry, 4326), TEXT, JSON, INTEGER);
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
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetBoundariesByPointAndRadius(TEXT, TEXT, geometry(Point, 4326), NUMERIC, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetBoundariesByPointAndRadius(TEXT, TEXT, geometry(Point, 4326), NUMERIC, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetPointsByGeometry(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetPointsByGeometry(TEXT, TEXT, geometry(Point, 4326), TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetPointsByPointAndRadius(TEXT, TEXT, geometry(Point, 4326), NUMERIC, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetPointsByPointAndRadius(TEXT, TEXT, geometry(Point, 4326), NUMERIC, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._DST_ConnectUserTable(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.__DST_ConnectUserTable(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._DST_GetReturnMetadata(TEXT, TEXT, TEXT, JSON);
DROP FUNCTION IF EXISTS cdb_dataservices_server._DST_FetchJoinFdwTableData(TEXT, TEXT, TEXT, TEXT, TEXT, JSON);
DROP FUNCTION IF EXISTS cdb_dataservices_server._DST_DisconnectUserTable(TEXT, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_DumpVersion(TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetAvailableNumerators(TEXT, TEXT, geometry(Geometry, 4326), TEXT[], TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetAvailableDenominators(TEXT, TEXT, geometry(Geometry, 4326), TEXT[], TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetAvailableGeometries(TEXT, TEXT, geometry(Geometry, 4326), TEXT[], TEXT, TEXT, TEXT, INTEGER);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_GetAvailableTimespans(TEXT, TEXT, geometry(Geometry, 4326), TEXT[], TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.OBS_LegacyBuilderMetadata(TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._OBS_GetNumerators (TEXT, TEXT, geometry(Geometry, 4326), TEXT[], TEXT[] , TEXT[], TEXT[] , TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._get_obs_config(TEXT, TEXT);

DROP TYPE IF EXISTS cdb_dataservices_server.obs_meta_numerator;
DROP TYPE IF EXISTS cdb_dataservices_server.obs_meta_denominator;
DROP TYPE IF EXISTS cdb_dataservices_server.obs_meta_geometry;
DROP TYPE IF EXISTS cdb_dataservices_server.obs_meta_timespan;
DROP TYPE IF EXISTS cdb_dataservices_server.ds_fdw_metadata;
DROP TYPE IF EXISTS cdb_dataservices_server.ds_return_metadata;

DELETE FROM pg_enum
WHERE enumlabel = 'observatory'
AND enumtypid = (
  SELECT pg_type.oid
  FROM pg_type INNER JOIN pg_namespace ON (pg_type.typnamespace = pg_namespace.oid)
  WHERE pg_type.typname = 'service_type' AND pg_namespace.nspname = 'cdb_dataservices_server'
);

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_quota_info(
  username TEXT,
  orgname TEXT)
RETURNS SETOF cdb_dataservices_server.service_quota_info AS $$
  from cartodb_services.metrics.user import UserMetricsService
  from datetime import date

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']

  today = date.today()
  ret = []

  #-- Isolines
  service = 'isolines'
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
  user_service = UserMetricsService(user_isolines_config, redis_conn)

  monthly_quota = user_isolines_config.isolines_quota
  used_quota = user_service.used_quota(user_isolines_config.service_type, today)
  soft_limit = user_isolines_config.soft_isolines_limit
  provider = user_isolines_config.provider
  ret += [[service, monthly_quota, used_quota, soft_limit, provider]]

  #-- Hires Geocoder
  service = 'hires_geocoder'
  plpy.execute("SELECT cdb_dataservices_server._get_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_geocoder_config_{0}".format(username)]
  user_service = UserMetricsService(user_geocoder_config, redis_conn)

  monthly_quota = user_geocoder_config.geocoding_quota
  used_quota = user_service.used_quota(user_geocoder_config.service_type, today)
  soft_limit = user_geocoder_config.soft_geocoding_limit
  provider = user_geocoder_config.provider
  ret += [[service, monthly_quota, used_quota, soft_limit, provider]]

  #-- Routing
  service = 'routing'
  plpy.execute("SELECT cdb_dataservices_server._get_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_routing_config = GD["user_routing_config_{0}".format(username)]
  user_service = UserMetricsService(user_routing_config, redis_conn)

  monthly_quota = user_routing_config.monthly_quota
  used_quota = user_service.used_quota(user_routing_config.service_type, today)
  soft_limit = user_routing_config.soft_limit
  provider = user_routing_config.provider
  ret += [[service, monthly_quota, used_quota, soft_limit, provider]]

  return ret
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;
