import unittest
from mock import Mock
from cartodb_services.tomtom import TomTomRouting
from cartodb_services.tomtom.routing import DEFAULT_PROFILE
from cartodb_services.tools.exceptions import ServiceException
from cartodb_services.tools import Coordinate
from credentials import tomtom_api_key

INVALID_APIKEY = 'invalid_apikey'
VALID_WAYPOINTS = [Coordinate(13.42936, 52.50931),
                   Coordinate(13.43872, 52.50274)]
NUM_WAYPOINTS_MAX = 20
INVALID_WAYPOINTS_EMPTY = []
INVALID_WAYPOINTS_MIN = [Coordinate(13.42936, 52.50931)]
INVALID_WAYPOINTS_MAX = [Coordinate(13.42936, 52.50931)
                         for x in range(0, NUM_WAYPOINTS_MAX + 2)]
VALID_PROFILE = DEFAULT_PROFILE
VALID_ROUTE_TYPE = 'fastest'
INVALID_PROFILE = 'invalid_profile'
INVALID_ROUTE_TYPE = 'invalid_route_type'


class TomTomRoutingTestCase(unittest.TestCase):
    def setUp(self):
        self.routing = TomTomRouting(apikey=tomtom_api_key(), logger=Mock())

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
        invalid_routing = TomTomRouting(apikey=INVALID_APIKEY, logger=Mock())
        with self.assertRaises(ServiceException):
            invalid_routing.directions(VALID_WAYPOINTS,
                                       VALID_PROFILE)
    def test_invalid_route_type(self):
        with self.assertRaises(ValueError):
            self.routing.directions(VALID_WAYPOINTS, VALID_PROFILE, route_type=INVALID_ROUTE_TYPE)

    def test_valid_request(self):
        route = self.routing.directions(VALID_WAYPOINTS, VALID_PROFILE)

        assert route.shape
        assert route.length
        assert route.duration

        route = self.routing.directions(VALID_WAYPOINTS, VALID_PROFILE, route_type=VALID_ROUTE_TYPE)

        assert route.shape
        assert route.length
        assert route.duration
