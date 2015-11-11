-- Interfacess of the server extension

---- geocode_namedplace(city_name text)
CREATE OR REPLACE FUNCTION geocode_namedplace(user_id name, tx_id bigint, city_name text)
RETURNS Geometry AS $$
    plpy.debug('Entering geocode_namedplace(city_name text)')
    plpy.debug('user_id = %s' % user_id)

    #-- Access control
    #-- TODO: this should be part of cdb python library
    if user_id == 'publicuser':
        plpy.error('The api_key must be provided')

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_geocoder_server._geocode_namedplace($1) AS mypoint", ["text"])
    rv = plpy.execute(plan, [city_name], 1)

    plpy.debug('Returning from Returning from geocode_namedplace')
    return rv[0]["mypoint"]
$$ LANGUAGE plpythonu;

---- geocode_admin1_polygons(admin1_name text, country_name text)

--------------------------------------------------------------------------------

-- Implementation of the server extension
-- Note: these functions depend on the cdb_geocoder extension

---- geocode_namedplace(city_name text)
CREATE OR REPLACE FUNCTION _geocode_namedplace(city_name text)
RETURNS Geometry AS $$
  DECLARE
    ret Geometry;
  BEGIN
  SELECT geom INTO ret
  FROM (
    WITH best AS (SELECT s AS q, (SELECT the_geom FROM global_cities_points_limited gp WHERE gp.lowername = lower(p.s) ORDER BY population DESC LIMIT 1) AS geom FROM (SELECT city_name as s) p),
        next AS (SELECT p.s AS q, (SELECT gp.the_geom FROM global_cities_points_limited gp, global_cities_alternates_limited ga WHERE lower(p.s) = ga.lowername AND ga.geoname_id = gp.geoname_id ORDER BY preferred DESC LIMIT 1) geom FROM (SELECT city_name as s) p WHERE p.s NOT IN (SELECT q FROM best WHERE geom IS NOT NULL))
        SELECT q, geom, TRUE AS success FROM best WHERE geom IS NOT NULL
        UNION ALL
        SELECT q, geom, CASE WHEN geom IS NULL THEN FALSE ELSE TRUE END AS success FROM next
  ) v;

    RETURN ret;
  END
$$ LANGUAGE plpgsql;

---- geocode_namedplace(city_name text, country_name text)


