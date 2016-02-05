-- Interface of the server extension

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_ipaddress_point(username text, orgname text, ip text)
RETURNS Geometry AS $$
    plpy.debug('Entering _cdb_geocode_ipaddress_point')
    plpy.debug('user = %s' % username)

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_ipaddress_point($1) AS point", ["TEXT"])
    rv = plpy.execute(plan, [ip], 1)

    plpy.debug('Returning from _cdb_geocode_ipaddress_point')
    return rv[0]["point"]
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
