import plpy


class Coordinate:
    """Class that represents a generic form of coordinates to be used
        by the services """

    def __init__(self, longitude, latitude):
        self._longitude = longitude
        self._latitude = latitude

    @property
    def latitude(self):
        return self._latitude

    @property
    def longitude(self):
        return self._longitude

    def to_json(self):
        return "{{\"lon\": {0},\"lat\": {1}}}".format(self._longitude,
                                                      self._latitude)

    def __str__(self):
        return "{0}, {1}".format(self._longitude, self._latitude)


def validate_coordinates(coordinates,
                         num_coordinates_min, num_coordinates_max):
    if not coordinates:
        raise ValueError('Invalid (empty) coordinates.')

    if len(coordinates) < num_coordinates_min \
            or len(coordinates) > num_coordinates_max:
        raise ValueError('Invalid number of coordinates. '
                         'Must be between {min} and {max}'.format(
                             min=num_coordinates_min,
                             max=num_coordinates_max))


def marshall_coordinates(coordinates):
    return ';'.join([str(coordinate).replace(' ', '')
                     for coordinate in coordinates])


def coordinates_to_polygon(coordinates):
    """Convert a Coordinate array coordinates to a PostGIS polygon"""
    coordinates.append(coordinates[0])  # Close the ring
    result_coordinates = []
    for coordinate in coordinates:
        result_coordinates.append("%s %s" % (coordinate.longitude,
                                             coordinate.latitude))
    wkt_coordinates = ','.join(result_coordinates)

    try:
        sql = "SELECT ST_CollectionExtract(ST_MakeValid(ST_MakePolygon(ST_GeomFromText('LINESTRING({0})', 4326))),3) as geom".format(wkt_coordinates)
        geometry = plpy.execute(sql, 1)[0]['geom']
    except BaseException as e:
        plpy.warning("Can't generate POLYGON from coordinates: {0}".format(e))
        geometry = None

    return geometry
