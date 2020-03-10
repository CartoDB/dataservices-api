-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.36.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapbox_isodistance(
   username TEXT,
   orgname TEXT,
   source geometry(Geometry, 4326),
   mode TEXT,
   data_range integer[],
   options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  from cartodb_services.tools import ServiceManager
  from cartodb_services.mapbox import MapboxMatrixClient, MapboxIsolines
  from cartodb_services.mapbox.types import TRANSPORT_MODE_TO_MAPBOX
  from cartodb_services.tools import Coordinate
  from cartodb_services.refactor.service.mapbox_isolines_config import MapboxIsolinesConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('isolines', MapboxIsolinesConfigBuilder, username, orgname, GD)
  service_manager.assert_within_limits()

  try:
    client = MapboxMatrixClient(service_manager.config.mapbox_api_key, service_manager.logger, service_manager.config.service_params)
    mapbox_isolines = MapboxIsolines(client, service_manager.logger)

    if source:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
      origin = Coordinate(lon,lat)
    else:
      raise Exception('source is NULL')

    profile = TRANSPORT_MODE_TO_MAPBOX.get(mode)

    # -- TODO Support options properly
    isolines = {}
    for r in data_range:
        isoline = mapbox_isolines.calculate_isodistance(origin, r, profile)
        isolines[r] = isoline

    result = []
    for r in data_range:

      if len(isolines[r]) >= 3:
        # -- TODO encapsulate this block into a func/method
        locations = isolines[r] + [ isolines[r][0] ] # close the polygon repeating the first point
        wkt_coordinates = ','.join(["%f %f" % (l.longitude, l.latitude) for l in locations])
        sql = "SELECT st_multi(ST_CollectionExtract(ST_MakeValid(ST_MPolyFromText('MULTIPOLYGON((({0})))', 4326)),3)) as geom".format(wkt_coordinates)
        multipolygon = plpy.execute(sql, 1)[0]['geom']
      else:
        multipolygon = None

      result.append([source, r, multipolygon])

    service_manager.quota_service.increment_success_service_use()
    service_manager.quota_service.increment_isolines_service_use(len(isolines))
    return result
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to get Mapbox isolines', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to get Mapbox isolines')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;


CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapbox_isochrones(
   username TEXT,
   orgname TEXT,
   source geometry(Geometry, 4326),
   mode TEXT,
   data_range integer[],
   options text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  from cartodb_services.tools import ServiceManager
  from cartodb_services.mapbox import MapboxMatrixClient, MapboxIsolines
  from cartodb_services.mapbox.types import TRANSPORT_MODE_TO_MAPBOX
  from cartodb_services.tools import Coordinate
  from cartodb_services.tools.coordinates import coordinates_to_polygon
  from cartodb_services.refactor.service.mapbox_isolines_config import MapboxIsolinesConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_manager = ServiceManager('isolines', MapboxIsolinesConfigBuilder, username, orgname, GD)
  service_manager.assert_within_limits()

  try:
    client = MapboxMatrixClient(service_manager.config.mapbox_api_key, service_manager.logger, service_manager.config.service_params)
    mapbox_isolines = MapboxIsolines(client, service_manager.logger)

    if source:
      lat = plpy.execute("SELECT ST_Y('%s') AS lat" % source)[0]['lat']
      lon = plpy.execute("SELECT ST_X('%s') AS lon" % source)[0]['lon']
      origin = Coordinate(lon,lat)
    else:
      raise Exception('source is NULL')

    profile = TRANSPORT_MODE_TO_MAPBOX.get(mode)

    resp = mapbox_isolines.calculate_isochrone(origin, data_range, profile)

    if resp:
      result = []
      for isochrone in resp:
        result_polygon = coordinates_to_polygon(isochrone.coordinates)
        if result_polygon:
          result.append([source, isochrone.duration, result_polygon])
        else:
          result.append([source, isochrone.duration, None])
      service_manager.quota_service.increment_success_service_use()
      service_manager.quota_service.increment_isolines_service_use(len(result))
      return result
    else:
      service_manager.quota_service.increment_empty_service_use()
      return []
  except BaseException as e:
    import sys
    service_manager.quota_service.increment_failed_service_use()
    service_manager.logger.error('Error trying to get Mapbox isochrones', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to get Mapbox isochrones')
  finally:
    service_manager.quota_service.increment_total_service_use()
$$ LANGUAGE @@plpythonu@@ SECURITY DEFINER STABLE PARALLEL RESTRICTED;
