--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.13.0'" to load this file. \quit


DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_admin0_polygon_exception_safe(country_name text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_admin1_polygon_exception_safe(admin1_name text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_admin1_polygon_exception_safe(admin1_name text, country_name text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_namedplace_point_exception_safe(city_name text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_namedplace_point_exception_safe(city_name text, country_name text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_namedplace_point_exception_safe(city_name text, admin1_name text, country_name text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_postalcode_polygon_exception_safe(postal_code text, country_name text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_postalcode_point_exception_safe(postal_code text, country_name text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_ipaddress_point_exception_safe(ip_address text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_here_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_google_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapzen_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_isodistance_exception_safe(source geometry(Geometry, 4326), mode text, range integer[], options text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_isochrone_exception_safe(source geometry(Geometry, 4326), mode text, range integer[], options text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapzen_isochrone_exception_safe(source geometry(Geometry, 4326), mode text, range integer[], options text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapzen_isodistance_exception_safe(source geometry(Geometry, 4326), mode text, range integer[], options text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_route_point_to_point_exception_safe(origin geometry(Point, 4326), destination geometry(Point, 4326), mode text, options text[], units text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_route_with_waypoints_exception_safe(waypoints geometry(Point, 4326)[], mode text, options text[], units text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_get_demographic_snapshot_exception_safe(geom geometry(Geometry, 4326), time_span text, geometry_level text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_get_segment_snapshot_exception_safe(geom geometry(Geometry, 4326), geometry_level text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getdemographicsnapshot_exception_safe(geom geometry(Geometry, 4326), time_span text, geometry_level text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getsegmentsnapshot_exception_safe(geom geometry(Geometry, 4326), geometry_level text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getboundary_exception_safe(geom geometry(Geometry, 4326), boundary_id text, time_span text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getboundaryid_exception_safe(geom geometry(Geometry, 4326), boundary_id text, time_span text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getboundarybyid_exception_safe(geometry_id text, boundary_id text, time_span text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getboundariesbygeometry_exception_safe(geom geometry(Geometry, 4326), boundary_id text, time_span text, overlap_type text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getboundariesbypointandradius_exception_safe(geom geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text, overlap_type text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getpointsbygeometry_exception_safe(geom geometry(Geometry, 4326), boundary_id text, time_span text, overlap_type text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getpointsbypointandradius_exception_safe(geom geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text, overlap_type text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getmeasure_exception_safe(geom Geometry, measure_id text, normalize text, boundary_id text, time_span text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getmeasurebyid_exception_safe(geom_ref text, measure_id text, boundary_id text, time_span text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getcategory_exception_safe(geom Geometry, category_id text, boundary_id text, time_span text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getuscensusmeasure_exception_safe(geom Geometry, name text, normalize text, boundary_id text, time_span text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getuscensuscategory_exception_safe(geom Geometry, name text, boundary_id text, time_span text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getpopulation_exception_safe(geom Geometry, normalize text, boundary_id text, time_span text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_search_exception_safe(search_term text, relevant_boundary text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getavailableboundaries_exception_safe(geom Geometry, timespan text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_dumpversion_exception_safe();
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getavailablenumerators_exception_safe(bounds geometry(Geometry, 4326), filter_tags text[], denom_id text, geom_id text, timespan text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getavailabledenominators_exception_safe(bounds geometry(Geometry, 4326), filter_tags text[], numer_id text, geom_id text, timespan text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getavailablegeometries_exception_safe(bounds geometry(Geometry, 4326), filter_tags text[], numer_id text, denom_id text, timespan text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getavailabletimespans_exception_safe(bounds geometry(Geometry, 4326), filter_tags text[], numer_id text, denom_id text, geom_id text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_legacybuildermetadata_exception_safe(aggregate_type text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_quota_info_exception_safe();
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_enough_quota_exception_safe(service TEXT, input_size NUMERIC);

