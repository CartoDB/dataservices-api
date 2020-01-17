import unittest
from mock import Mock
from cartodb_services.mapbox.true_isolines import MapboxTrueIsolines, DEFAULT_PROFILE
from cartodb_services.tools import Coordinate

from credentials import mapbox_api_key

VALID_ORIGIN = Coordinate(-73.989, 40.733)


class MapboxTrueIsolinesTestCase(unittest.TestCase):

    def setUp(self):
        self.mapbox_isolines = MapboxTrueIsolines(apikey=mapbox_api_key(),
                                                  logger=Mock())

    def test_calculate_isochrone(self):
        time_ranges = [300, 900]
        solution = self.mapbox_isolines.calculate_isochrone(
            origin=VALID_ORIGIN,
            profile=DEFAULT_PROFILE,
            time_ranges=time_ranges)

        assert solution

    def test_calculate_isodistance(self):
        distance_range = 10000
        solution = self.mapbox_isolines.calculate_isodistance(
            origin=VALID_ORIGIN,
            profile=DEFAULT_PROFILE,
            distance_range=distance_range)

        assert solution
