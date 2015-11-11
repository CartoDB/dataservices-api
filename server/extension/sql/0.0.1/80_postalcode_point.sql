-- Interface of the server extension

CREATE OR REPLACE FUNCTION geocode_postalcode_point(user_id NAME, tx_id BIGINT, code text)
RETURNS Geometry AS $$
    plpy.debug('Entering _geocode_postalcode_point')
    plpy.debug('user_id = %s' % user_id)

    #-- Access control
    #-- TODO: this should be part of cdb python library
    if user_id == 'publicuser':
        plpy.error('The api_key must be provided')

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_geocoder_server._geocode_postalcode_point($1) AS point", ["text"])
    rv = plpy.execute(plan, [code], 1)

    plpy.debug('Returning from _geocode_postalcode_point')
    return rv[0]["point"]
$$ LANGUAGE plpythonu;


--------------------------------------------------------------------------------

-- Implementation of the server extension
-- Note: these functions depend on the cdb_geocoder extension
CREATE OR REPLACE FUNCTION _geocode_postalcode_point(code text)
RETURNS Geometry AS $$
  DECLARE
    ret Geometry;
  BEGIN
    SELECT geom INTO ret
    FROM (
      SELECT
        q, (
          SELECT the_geom
          FROM global_postal_code_points
          WHERE postal_code = upper(d.q)
          LIMIT 1
        ) geom
      FROM (SELECT code q) d
    ) v;

    RETURN ret;
END
$$ LANGUAGE plpgsql;
