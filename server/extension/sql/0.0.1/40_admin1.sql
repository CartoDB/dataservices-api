-- Interfacess of the server extension

---- geocode_admin1_polygons(admin1_name text)
CREATE OR REPLACE FUNCTION geocode_admin1_polygons(user_id name, tx_id bigint, admin1_name text)
RETURNS Geometry AS $$
    plpy.debug('Entering geocode_admin1_polygons(admin1_name text)')
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

---- geocode_admin1_polygons(admin1_name text, country_name text)
CREATE OR REPLACE FUNCTION geocode_admin1_polygons(user_id name, tx_id bigint, admin1_name text, country_name text)
RETURNS Geometry AS $$
    plpy.debug('Entering geocode_admin1_polygons(admin1_name text, country_name text)')
    plpy.debug('user_id = %s' % user_id)

    #-- Access control
    #-- TODO: this should be part of cdb python library
    if user_id == 'publicuser':
        plpy.error('The api_key must be provided')

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_geocoder_server._geocode_admin1_polygons($1, $2) AS mypolygon", ["text", "text"])
    rv = plpy.execute(plan, [admin1_name, country_name], 1)

    plpy.debug('Returning from Returning from geocode_admin1_polygons(admin1_name text, country_name text)')
    return rv[0]["mypolygon"]
$$ LANGUAGE plpythonu;

--------------------------------------------------------------------------------

-- Implementation of the server extension
-- Note: these functions depend on the cdb_geocoder extension

---- geocode_admin1_polygons(admin1_name text)
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

---- geocode_admin1_polygons(admin1_name text, country_name text)
CREATE OR REPLACE FUNCTION _geocode_admin1_polygons(admin1_name text, country_name text)
RETURNS Geometry AS $$
  DECLARE
    ret Geometry;
  BEGIN
    WITH p AS (SELECT r.c, r.q, (SELECT iso3 FROM country_decoder WHERE lower(country_name) = ANY (synonyms)) i FROM (SELECT  trim(replace(lower(admin1_name),'.',' ')) c, country_name q) r)
    SELECT
      geom INTO ret
    FROM (
      SELECT 
        q, (
          SELECT the_geom 
          FROM global_province_polygons
          WHERE p.c = ANY (synonyms) 
          AND iso3 = p.i
          ORDER BY frequency DESC LIMIT 1
        ) geom
      FROM p) n;

    RETURN ret;
  END
$$ LANGUAGE plpgsql;

