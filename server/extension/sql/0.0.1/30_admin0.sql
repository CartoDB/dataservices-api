-- Interface of the server extension

CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_admin0_polygon(user_id name, user_config_data JSON, geocoder_config_data JSON, country_name text)
RETURNS Geometry AS $$
    plpy.debug('Entering geocode_admin0_polygons')
    plpy.debug('user_id = %s' % user_id)

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_geocoder_server._geocode_admin0_polygon($1) AS mypolygon", ["text"])
    rv = plpy.execute(plan, [country_name], 1)

    plpy.debug('Returning from Returning from geocode_admin0_polygons')
    return rv[0]["mypolygon"]
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
