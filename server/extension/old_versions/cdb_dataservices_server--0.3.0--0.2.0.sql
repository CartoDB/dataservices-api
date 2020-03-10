CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_admin0_polygon(username text, orgname text, country_name text)
RETURNS Geometry AS $$
    plpy.debug('Entering cdb_geocode_admin0_polygons')
    plpy.debug('user = %s' % username)

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_admin0_polygon($1) AS mypolygon", ["text"])
    rv = plpy.execute(plan, [country_name], 1)

    plpy.debug('Returning from Returning from cdb_geocode_admin0_polygons')
    return rv[0]["mypolygon"]
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_admin1_polygon(username text, orgname text, admin1_name text)
RETURNS Geometry AS $$
    plpy.debug('Entering cdb_geocode_admin1_polygon(admin1_name text)')
    plpy.debug('user = %s' % username)

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_admin1_polygon($1) AS mypolygon", ["text"])
    rv = plpy.execute(plan, [admin1_name], 1)

    plpy.debug('Returning from Returning from cdb_geocode_admin1_polygons')
    return rv[0]["mypolygon"]
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_admin1_polygon(username text, orgname text, admin1_name text, country_name text)
RETURNS Geometry AS $$
    plpy.debug('Entering cdb_geocode_admin1_polygon(admin1_name text, country_name text)')
    plpy.debug('user = %s' % username)

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_admin1_polygon($1, $2) AS mypolygon", ["text", "text"])
    rv = plpy.execute(plan, [admin1_name, country_name], 1)

    plpy.debug('Returning from Returning from cdb_geocode_admin1_polygon(admin1_name text, country_name text)')
    return rv[0]["mypolygon"]
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text)
RETURNS Geometry AS $$
    plpy.debug('Entering cdb_geocode_namedplace_point(city_name text)')
    plpy.debug('user = %s' % username)

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_namedplace_point($1) AS mypoint", ["text"])
    rv = plpy.execute(plan, [city_name], 1)

    plpy.debug('Returning from Returning from geocode_namedplace')
    return rv[0]["mypoint"]
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text, country_name text)
RETURNS Geometry AS $$
    plpy.debug('Entering cdb_geocode_namedplace_point(city_name text, country_name text)')
    plpy.debug('user = %s' % username)

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_namedplace_point($1, $2) AS mypoint", ["text", "text"])
    rv = plpy.execute(plan, [city_name, country_name], 1)

    plpy.debug('Returning from Returning from geocode_namedplace')
    return rv[0]["mypoint"]
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text, admin1_name text, country_name text)
RETURNS Geometry AS $$
    plpy.debug('Entering cdb_geocode_namedplace_point(city_name text, admin1_name text, country_name text)')
    plpy.debug('user = %s' % username)

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_namedplace_point($1, $2, $3) AS mypoint", ["text", "text", "text"])
    rv = plpy.execute(plan, [city_name, admin1_name, country_name], 1)

    plpy.debug('Returning from Returning from geocode_namedplace')
    return rv[0]["mypoint"]
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_point(username text, orgname text, code text)
RETURNS Geometry AS $$
    plpy.debug('Entering _cdb_geocode_postalcode_point')
    plpy.debug('user = %s' % username)

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_postalcode_point($1) AS point", ["text"])
    rv = plpy.execute(plan, [code], 1)

    plpy.debug('Returning from _cdb_geocode_postalcode_point')
    return rv[0]["point"]
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_point(username text, orgname text, code text, country text)
RETURNS Geometry AS $$
    plpy.debug('Entering _cdb_geocode_postalcode_point')
    plpy.debug('user = %s' % username)

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_postalcode_point($1, $2) AS point", ["TEXT", "TEXT"])
    rv = plpy.execute(plan, [code, country], 1)

    plpy.debug('Returning from _cdb_geocode_postalcode_point')
    return rv[0]["point"]
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_polygon(username text, orgname text, code text)
RETURNS Geometry AS $$
    plpy.debug('Entering _cdb_geocode_postalcode_polygon')
    plpy.debug('user = %s' % username)

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_postalcode_polygon($1) AS polygon", ["text"])
    rv = plpy.execute(plan, [code], 1)

    plpy.debug('Returning from _cdb_geocode_postalcode_polygon')
    return rv[0]["polygon"]
$$ LANGUAGE @@plpythonu@@;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_postalcode_polygon(username text, orgname text, code text, country text)
RETURNS Geometry AS $$
    plpy.debug('Entering _cdb_geocode_postalcode_point')
    plpy.debug('user = %s' % username)

    #--TODO: rate limiting check
    #--TODO: quota check

    #-- Copied from the doc, see http://www.postgresql.org/docs/9.4/static/plpython-database.html
    plan = plpy.prepare("SELECT cdb_dataservices_server._cdb_geocode_postalcode_polygon($1, $2) AS polygon", ["TEXT", "TEXT"])
    rv = plpy.execute(plan, [code, country], 1)

    plpy.debug('Returning from _cdb_geocode_postalcode_point')
    return rv[0]["polygon"]
$$ LANGUAGE @@plpythonu@@;

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
$$ LANGUAGE @@plpythonu@@;
