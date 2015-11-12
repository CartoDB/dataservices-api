-- Interface of the server extension

CREATE OR REPLACE FUNCTION geocode_ip_point(user_id NAME, tx_id BIGINT, ip TEXT)
RETURNS Geometry AS $$
    plpy.debug('Entering _geocode_ip_point')
    plpy.debug('user_id = %s' % user_id)

    #-- Access control
    #-- TODO: this should be part of cdb python library
    if user_id == 'publicuser':
        plpy.error('The api_key must be provided')

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_geocoder_server._geocode_ip_point($1) AS point", ["TEXT"])
    rv = plpy.execute(plan, [ip], 1)

    plpy.debug('Returning from _geocode_ip_point')
    return rv[0]["point"]
$$ LANGUAGE plpythonu;


--------------------------------------------------------------------------------

-- Implementation of the server extension
-- Note: these functions depend on the cdb_geocoder extension
CREATE OR REPLACE FUNCTION _geocode_ip_point(ip TEXT)
RETURNS Geometry AS $$
    DECLARE
        ret Geometry;

        new_ips INET[];
        old_ips TEXT[];
    BEGIN
    BEGIN
        IF family(ip::inet) = 6 THEN
            new_ips := array_append(new_ips, ip::inet);
            old_ips := array_append(old_ips, ip);
        ELSE
            new_ips := array_append(new_ips, ('::ffff:' || ip)::inet);
            old_ips := array_append(old_ips, ip);
        END IF;
    EXCEPTION WHEN OTHERS THEN
        SELECT ip AS q, NULL as geom, FALSE as success INTO ret;
        RETURN ret;
    END;

    WITH
        ips AS (SELECT unnest(old_ips) s, unnest(new_ips) net),
        matches AS (SELECT s, (SELECT the_geom FROM ip_address_locations WHERE network_start_ip <= ips.net ORDER BY network_start_ip DESC LIMIT 1) geom FROM ips)
        SELECT geom INTO ret
        FROM matches;
    RETURN ret;
END
$$ LANGUAGE plpgsql;
