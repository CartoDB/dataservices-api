-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.36.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade

DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_mapbox_iso_isodistance;

DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_mapbox_iso_isochrones;

DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_mapbox_iso_isodistance;

DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_mapbox_iso_isochrone;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_isodistance(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  if user_isolines_config.google_services_user:
    raise Exception('This service is not available for google service users.')

  params = {'username': username, 'orgname': orgname, 'source': source, 'mode': mode, 'range': range, 'options': options}

  with metrics('cdb_isodistance', user_isolines_config, logger, params):
    if user_isolines_config.heremaps_provider:
      here_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_here_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(here_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapzen_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapzen_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapbox_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapbox_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.tomtom_provider:
      tomtom_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_tomtom_isodistance($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(tomtom_plan, [username, orgname, source, mode, range, options])
    else:
      raise Exception('Requested isolines provider is not available')
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_isochrone(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT array[]::text[])
RETURNS SETOF cdb_dataservices_server.isoline AS $$
  from cartodb_services.metrics import metrics
  from cartodb_services.tools import Logger

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_isolines_routing_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_isolines_config = GD["user_isolines_routing_config_{0}".format(username)]
  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)

  if user_isolines_config.google_services_user:
    raise Exception('This service is not available for google service users.')

  params = {'username': username, 'orgname': orgname, 'source': source, 'mode': mode, 'range': range, 'options': options}

  with metrics('cdb_isochrone', user_isolines_config, logger, params):
    if user_isolines_config.heremaps_provider:
      here_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_here_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(here_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapzen_provider:
      mapzen_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapzen_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapzen_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.mapbox_provider:
      mapbox_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_mapbox_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(mapbox_plan, [username, orgname, source, mode, range, options])
    elif user_isolines_config.tomtom_provider:
      tomtom_plan = plpy.prepare("SELECT * FROM cdb_dataservices_server.cdb_tomtom_isochrone($1, $2, $3, $4, $5, $6) as isoline; ", ["text", "text", "geometry(geometry, 4326)", "text", "integer[]", "text[]"])
      return plpy.execute(tomtom_plan, [username, orgname, source, mode, range, options])
    else:
      raise Exception('Requested isolines provider is not available')
$$ LANGUAGE plpythonu STABLE PARALLEL RESTRICTED;
