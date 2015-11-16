-- Interface of the server extension

CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_admin0_polygon(user_id name, tx_id bigint, country_name text)
RETURNS Geometry AS $$
    from cartodb_geocoder import quota_service
    plpy.debug('Entering geocode_admin0_polygons')
    plpy.debug('user_id = %s' % user_id)

    #-- Access control
    #-- TODO: this should be part of cdb python library
    if user_id == 'publicuser':
        plpy.error('The api_key must be provided')

    #--TODO: rate limiting check
    #--This will create and cache a redis connection, if needed, in the GD object for the current user
    redis_conn_plan = plpy.prepare("SELECT cdb_geocoder_server._connect_to_redis($1)", ["name"])
    redis_conn_result = plpy.execute(redis_conn_plan, [user_id], 1)
    qs = quota_service.QuotaService(user_id, tx_id, GD[user_id]['redis_connection'])

    if not qs.check_user_quota():
      plpy.error("Not enough quota for this user")

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_geocoder_server._geocode_admin0_polygon($1) AS mypolygon", ["text"])
    result = plpy.execute(plan, [country_name], 1)
    if result.status() == 5 and result.nrows() == 1:
      qs.increment_geocoder_use()
      plpy.debug('Returning from geocode_admin0_polygons')
      return result[0]["mypolygon"]
    else:
      plpy.error('Something wrong with the georefence operation')
$$ LANGUAGE plpythonu;


--------------------------------------------------------------------------------

-- Implementation of the server extension
-- Note: these functions depend on the cdb_geocoder extension
CREATE OR REPLACE FUNCTION cdb_geocoder_server._geocode_admin0_polygon(country_name text)
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
