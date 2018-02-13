import unittest
from mock import Mock
from cartodb_services.mapbox.isolines import MapboxIsolines
from cartodb_services.mapbox.matrix_client import DEFAULT_PROFILE
from cartodb_services.mapbox.matrix_client import MapboxMatrixClient
from cartodb_services.mapbox.routing import MapboxRouting
from cartodb_services.tools import Coordinate
from cartodb_services.tools.coordinates import (validate_coordinates,
                                                marshall_coordinates)
from credentials import mapbox_api_key

VALID_ORIGIN = Coordinate(-73.989, 40.733)


class MapboxIsolinesTestCase(unittest.TestCase):

    def setUp(self):
        matrix_client = MapboxMatrixClient(token=mapbox_api_key(), logger=Mock())
        self.mapbox_isolines = MapboxIsolines(matrix_client, logger=Mock())

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
