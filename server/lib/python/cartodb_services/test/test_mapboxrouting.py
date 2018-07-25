import unittest
from mock import Mock
from cartodb_services.mapbox import MapboxRouting
from cartodb_services.mapbox.routing import DEFAULT_PROFILE
from cartodb_services.tools.exceptions import ServiceException
from cartodb_services.tools import Coordinate
from credentials import mapbox_api_key

INVALID_TOKEN = 'invalid_token'
VALID_WAYPOINTS = [Coordinate(-73.989, 40.733), Coordinate(-74, 40.733)]
NUM_WAYPOINTS_MAX = 25
INVALID_WAYPOINTS_EMPTY = []
INVALID_WAYPOINTS_MIN = [Coordinate(-73.989, 40.733)]
INVALID_WAYPOINTS_MAX = [Coordinate(-73.989, 40.733)
                         for x in range(0, NUM_WAYPOINTS_MAX + 2)]
VALID_PROFILE = DEFAULT_PROFILE
INVALID_PROFILE = 'invalid_profile'

WELL_KNOWN_SHAPE = [(40.73312, -73.98891), (40.73353, -73.98987),
                    (40.73398, -73.99095), (40.73321, -73.99111),
                    (40.73245, -73.99129), (40.7333, -73.99332),
                    (40.7338, -73.99449),  (40.73403, -73.99505),
                    (40.73344, -73.99549), (40.73286, -73.9959),
                    (40.73226, -73.99635), (40.73186, -73.99664),
                    (40.73147, -73.99693), (40.73141, -73.99698),
                    (40.73147, -73.99707), (40.73219, -73.99856),
                    (40.73222, -73.99861), (40.73225, -73.99868),
                    (40.73293, -74.00007), (40.733, -74.00001)]
WELL_KNOWN_LENGTH = 1384.8


class MapboxRoutingTestCase(unittest.TestCase):
    def setUp(self):
        self.routing = MapboxRouting(token=mapbox_api_key(), logger=Mock())

    def test_invalid_profile(self):
        with self.assertRaises(ValueError):
            self.routing.directions(VALID_WAYPOINTS, INVALID_PROFILE)

    def test_invalid_waypoints_empty(self):
        with self.assertRaises(ValueError):
            self.routing.directions(INVALID_WAYPOINTS_EMPTY, VALID_PROFILE)

    def test_invalid_waypoints_min(self):
        with self.assertRaises(ValueError):
            self.routing.directions(INVALID_WAYPOINTS_MIN, VALID_PROFILE)

    def test_invalid_waypoints_max(self):
        with self.assertRaises(ValueError):
            self.routing.directions(INVALID_WAYPOINTS_MAX, VALID_PROFILE)

    def test_invalid_token(self):
        invalid_routing = MapboxRouting(token=INVALID_TOKEN, logger=Mock())
        with self.assertRaises(ServiceException):
            invalid_routing.directions(VALID_WAYPOINTS,
                                       VALID_PROFILE)

    def test_valid_request(self):
        route = self.routing.directions(VALID_WAYPOINTS, VALID_PROFILE)

        self.assertEqual(route.shape, WELL_KNOWN_SHAPE)
        self.assertEqual(route.length, WELL_KNOWN_LENGTH)
        assert route.duration  # The duration may change between executions
