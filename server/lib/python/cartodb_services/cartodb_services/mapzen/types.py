import plpy


def polyline_to_linestring(polyline):
    """Convert a Mapzen polyline shape to a PostGIS multipolygon"""
    coordinates = []
    for point in polyline:
        # Divide by 10 because mapzen uses one more decimal than the
        # google standard (https://mapzen.com/documentation/turn-by-turn/decoding/)
        coordinates.append("%s %s" % (point[1]/10, point[0]/10))
    wkt_coordinates = ','.join(coordinates)

    sql = "SELECT ST_GeomFromText('LINESTRING({0})', 4326) as geom".format(wkt_coordinates)
    geometry = plpy.execute(sql, 1)[0]['geom']

    return geometry
