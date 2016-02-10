# Helper to deal with type conversion between HERE and PostGIS
import plpy


def geo_polyline_to_multipolygon(polyline):
    """Convert a HERE polyline shape to a PostGIS multipolygon"""
    coordinates = []
    for point in polyline:
        lat, lon = point.split(',')
        coordinates.append("%s %s" % (lon, lat))
    wkt_coordinates = ','.join(coordinates)

    sql = "SELECT ST_MPolyFromText('MULTIPOLYGON((({0})))', 4326) as geom".format(wkt_coordinates)
    geometry = plpy.execute(sql, 1)[0]['geom']

    return geometry
