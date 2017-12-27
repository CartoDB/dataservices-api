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
