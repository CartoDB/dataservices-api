CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_admin0_polygon(username text, orgname text, country_name text)
RETURNS Geometry AS $$
  from cartodb_services.metrics import QuotaService
  from cartodb_services.metrics import InternalGeocoderConfig
  from cartodb_services.tools import Logger,LoggerConfig

  plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
  redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
  plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
  user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

  plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
  logger_config = GD["logger_config"]
  logger = Logger(logger_config)
  quota_service = QuotaService(user_geocoder_config, redis_conn)
  try:
    plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_admin0_polygon(trim($1)) AS mypolygon", ["text"])
    rv = plpy.execute(plan, [country_name], 1)
    result = rv[0]["mypolygon"]
    if result:
      quota_service.increment_success_service_use()
      return result
    else:
      quota_service.increment_empty_service_use()
      return None
  except BaseException as e:
    import sys
    quota_service.increment_failed_service_use()
    logger.error('Error trying to geocode admin0 polygon', sys.exc_info(), data={"username": username, "orgname": orgname})
    raise Exception('Error trying to geocode admin0 polygon')
  finally:
    quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;


--------------------------------------------------------------------------------

-- Implementation of the server extension
-- Note: these functions depend on the cdb_geocoder extension
CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_geocode_admin0_polygon(country_name text)
RETURNS Geometry AS $$
  DECLARE
    ret Geometry;
  BEGIN
    SELECT n.the_geom as geom INTO ret
      FROM (SELECT q, lower(regexp_replace(q, '[^a-zA-Z\u00C0-\u00ff]+', '', 'g'))::text x
        FROM (SELECT country_name q) g) d
      LEFT OUTER JOIN admin0_synonyms s ON name_ = d.x
      LEFT OUTER JOIN ne_admin0_v3 n ON s.adm0_a3 = n.adm0_a3 GROUP BY d.q, n.the_geom, s.adm0_a3;

    RETURN ret;
  END
$$ LANGUAGE plpgsql;
