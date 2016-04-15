import plpy


def polyline_to_linestring(polyline):
    """Convert a Mapzen polyline shape to a PostGIS multipolygon"""
    coordinates = []
    for point in polyline:
        # Divide by 10 because mapzen uses one more decimal than the
        # google standard (https://mapzen.com/documentation/turn-by-turn/decoding/)
        coordinates.append("%s %s" % (point[1]/10, point[0]/10))
    wkt_coordinates = ','.join(coordinates)

    try:
        sql = "SELECT ST_GeomFromText('LINESTRING({0})', 4326) as geom".format(wkt_coordinates)
        geometry = plpy.execute(sql, 1)[0]['geom']
    except BaseException as e:
        plpy.warning("Can't generate LINESTRING from polyline: {0}".format(e))
        geometry = None

    return geometry

def country_to_iso3(country):
    """ Convert country to its iso3 code """
    try:
        country_plan = plpy.prepare("SELECT adm0_a3 as iso3 FROM admin0_synonyms WHERE lower(regexp_replace($1, " \
                                    "'[^a-zA-Z\u00C0-\u00ff]+', '', 'g'))::text = name_; ", ['text'])
        country_result = plpy.execute(country_plan, [country], 1)
        if country_result:
            return country_result[0]['iso3']
        else:
            return None
    except BaseException as e:
        plpy.warning("Can't get the iso3 code from {0}: {1}".format(country, e))
        return None
