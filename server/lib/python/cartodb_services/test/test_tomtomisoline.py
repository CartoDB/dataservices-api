import unittest
from mock import Mock
from cartodb_services.tomtom.isolines import TomTomIsolines, DEFAULT_PROFILE
from cartodb_services.tools import Coordinate

from credentials import tomtom_api_key

VALID_ORIGIN = Coordinate(-73.989, 40.733)


class TomTomIsolinesTestCase(unittest.TestCase):

    def setUp(self):
        self.tomtom_isolines = TomTomIsolines(apikey=tomtom_api_key(),
                                              logger=Mock())

    def test_calculate_isochrone(self):
        time_ranges = [300, 900]
        solution = self.tomtom_isolines.calculate_isochrone(
            origin=VALID_ORIGIN,
            profile=DEFAULT_PROFILE,
            time_ranges=time_ranges)

        assert solution

    def test_calculate_isodistance(self):
        distance_range = 10000
        solution = self.tomtom_isolines.calculate_isodistance(
            origin=VALID_ORIGIN,
            profile=DEFAULT_PROFILE,
            distance_range=distance_range)

        assert solution
