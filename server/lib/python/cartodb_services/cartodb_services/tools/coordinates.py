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
