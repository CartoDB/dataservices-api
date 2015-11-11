-- Interface of the server extension

CREATE OR REPLACE FUNCTION geocode_admin1_polygons(user_id name, tx_id bigint, admin1_name text)
RETURNS Geometry AS $$
    plpy.debug('Entering geocode_admin1_polygons')
    plpy.debug('user_id = %s' % user_id)

    #-- Access control
    #-- TODO: this should be part of cdb python library
    if user_id == 'publicuser':
        plpy.error('The api_key must be provided')

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_geocoder_server._geocode_admin1_polygons($1) AS mypolygon", ["text"])
    rv = plpy.execute(plan, [admin1_name], 1)

    plpy.debug('Returning from Returning from geocode_admin1_polygons')
    return rv[0]["mypolygon"]
$$ LANGUAGE plpythonu;


--------------------------------------------------------------------------------

-- Implementation of the server extension
-- Note: these functions depend on the cdb_geocoder extension
CREATE OR REPLACE FUNCTION _geocode_admin1_polygons(admin1_name text)
RETURNS Geometry AS $$
  DECLARE
    ret Geometry;
  BEGIN
    SELECT geom INTO ret
    FROM (
      SELECT q, (
          SELECT the_geom 
          FROM global_province_polygons
          WHERE d.c = ANY (synonyms) 
          ORDER BY frequency DESC LIMIT 1
        ) geom
      FROM (
        SELECT 
          trim(replace(lower(admin1_name),'.',' ')) c, admin1_name q
        ) d
      ) v;

    RETURN ret;
  END
$$ LANGUAGE plpgsql;
