CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_ipaddress_point(username text, orgname text, ip text)
RETURNS Geometry AS $$
    from cartodb_services.metrics import QuotaService
    from cartodb_services.metrics import InternalGeocoderConfig

    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metrics_connection']
    plpy.execute("SELECT cdb_dataservices_server._get_internal_geocoder_config({0}, {1})".format(plpy.quote_nullable(username), plpy.quote_nullable(orgname)))
    user_geocoder_config = GD["user_internal_geocoder_config_{0}".format(username)]

    quota_service = QuotaService(user_geocoder_config, redis_conn)
    try:
      plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_ipaddress_point(trim($1)) AS mypoint", ["TEXT"])
      rv = plpy.execute(plan, [ip], 1)
      result = rv[0]["mypoint"]
      if result:
        quota_service.increment_success_service_use()
        return result
      else:
        quota_service.increment_empty_service_use()
        return None
    except BaseException as e:
      import sys, traceback
      type_, value_, traceback_ = sys.exc_info()
      quota_service.increment_failed_service_use()
      error_msg = 'There was an error trying to geocode using admin0 geocoder: {0}'.format(e)
      plpy.notice(traceback.format_tb(traceback_))
      plpy.error(error_msg)
    finally:
      quota_service.increment_total_service_use()
$$ LANGUAGE plpythonu;

--------------------------------------------------------------------------------

-- Implementation of the server extension
-- Note: these functions depend on the cdb_geocoder extension
CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_geocode_ipaddress_point(ip text)
RETURNS Geometry AS $$
    DECLARE
        ret Geometry;

        new_ip INET;
    BEGIN
    BEGIN
        IF family(ip::inet) = 6 THEN
            new_ip := ip::inet;
        ELSE
            new_ip := ('::ffff:' || ip)::inet;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        SELECT NULL as geom INTO ret;
        RETURN ret;
    END;

    WITH
        ips AS (SELECT ip s, new_ip net),
        matches AS (SELECT s, (SELECT the_geom FROM ip_address_locations WHERE network_start_ip <= ips.net ORDER BY network_start_ip DESC LIMIT 1) geom FROM ips)
    SELECT geom INTO ret
        FROM matches;
    RETURN ret;
END
$$ LANGUAGE plpgsql;
