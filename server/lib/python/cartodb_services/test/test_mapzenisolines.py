import unittest
from mock import Mock
from cartodb_services.mapzen import MapzenIsolines
from math import radians, cos, sin, asin, sqrt

"""
This file is basically a sanity test on the algorithm.


It uses a mocked client, which returns the cost based on a very simple model:
just proportional to the distance from origin to the target point.
"""


class MatrixClientMock():

    def __init__(self, speed):
        """
        Sets up the mock with a speed in km/h
        """
        self._speed = speed

    def one_to_many(self, locations, costing):
        origin = locations[0]
        distances = [self._distance(origin, l) for l in locations]
        response = {
            'one_to_many': [
                [
                    {
                        'distance': distances[i] * self._speed,
                        'time': distances[i] / self._speed * 3600,
                        'to_index': i,
                        'from_index': 0
                    }
                    for i in xrange(0, len(distances))
                ]
            ],
            'units': 'km',
            'locations': [
                locations
            ]
        }
        return response

    def _distance(self, a, b):
        """
        Calculate the great circle distance between two points
        on the earth (specified in decimal degrees)
        http://stackoverflow.com/questions/4913349/haversine-formula-in-python-bearing-and-distance-between-two-gps-points

        Returns:
            distance in meters
        """

        # convert decimal degrees to radians
        lon1, lat1, lon2, lat2 = map(radians, [a['lon'], a['lat'], b['lon'], b['lat']])

        # haversine formula
        dlon = lon2 - lon1
        dlat = lat2 - lat1
        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
        c = 2 * asin(sqrt(a))
        r = 6371 # Radius of earth in kilometers. Use 3956 for miles
        return c * r


class MapzenIsolinesTestCase(unittest.TestCase):

    def setUp(self):
        speed = 4 # in km/h
        matrix_client = MatrixClientMock(speed)
        self.mapzen_isolines = MapzenIsolines(matrix_client, Mock())

    def test_calculate_isochrone(self):
        origin = {"lat":40.744014,"lon":-73.990508}
        transport_mode = 'walk'
        isorange = 10 * 60 # 10 minutes
        solution = self.mapzen_isolines.calculate_isochrone(origin, transport_mode, isorange)
