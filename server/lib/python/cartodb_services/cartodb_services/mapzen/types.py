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


def coordinates_to_polygon(coordinates):
    """Convert a Mapzen coordinates to a PostGIS polygon"""
    result_coordinates = []
    for coordinate in coordinates:
        result_coordinates.append("%s %s" % (coordinate[0], coordinate[1]))
    wkt_coordinates = ','.join(result_coordinates)

    try:
        sql = "SELECT ST_CollectionExtract(ST_MakeValid(ST_MakePolygon(ST_GeomFromText('LINESTRING({0})', 4326))),3) as geom".format(wkt_coordinates)
        geometry = plpy.execute(sql, 1)[0]['geom']
    except BaseException as e:
        plpy.warning("Can't generate POLYGON from coordinates: {0}".format(e))
        geometry = None

    return geometry
