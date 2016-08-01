#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import unittest
import requests_mock
import re
from nose.tools import assert_raises
from urlparse import urlparse, parse_qs
from mock import Mock

from cartodb_services.mapzen import MapzenRouting, MapzenRoutingResponse
from cartodb_services.mapzen.exceptions import WrongParams
from cartodb_services.tools import Coordinate

requests_mock.Mocker.TEST_PREFIX = 'test_'


@requests_mock.Mocker()
class MapzenRoutingTestCase(unittest.TestCase):

    GOOD_SHAPE_SIMPLE = [(38.5, -120.2), (43.2, -126.4)]

    GOOD_RESPONSE_SIMPLE = """{{
      "id": "ethervoid-route",
      "trip": {{
        "status": 0,
        "status_message": "Found route between points",
        "legs": [
          {{
            "shape": "_p~iF~ps|U_~t[~|yd@",
            "summary": {{
              "length": 444.59,
              "time": 16969
            }}
          }}
        ],
        "units": "kilometers",
        "summary": {{
          "length": 444.59,
          "time": 16969
        }},
        "locations": [
          {{
            "lon": -120.2,
            "lat": 38.5,
            "type": "break"
          }},
          {{
            "lon": -126.4,
            "lat": 43.2,
            "type": "break"
          }}
        ]
      }}
    }}""".format(GOOD_SHAPE_SIMPLE)

    GOOD_SHAPE_MULTI = [(40.4, -3.7), (40.1, -3.4), (40.6, -3.9)]

    GOOD_RESPONSE_MULTI = """{{
      "id": "ethervoid-route",
      "trip": {{
        "language":"en-US",
        "summary":{{
           "length": 1.261,
           "time": 913
        }},
        "locations":[
           {{
              "side_of_street":"right",
              "lon": -3.7,
              "lat": 40.4,
              "type":"break"
           }},
           {{
              "lon": -3.4,
              "lat": 40.1,
              "type": "through"
           }},
           {{
              "lon": -3.9,
              "lat": 40.6,
              "type": "break"
           }}
        ],
        "units":"kilometers",
        "legs":[
           {{
              "shape": "_squF~sqU~qy@_ry@_t`B~s`B",
              "summary": {{
                 "length":1.261,
                 "time":913
              }}
           }}
        ],
        "status_message": "Found route between points",
        "status": 0
      }}
    }}""".format(GOOD_SHAPE_MULTI)

    MALFORMED_RESPONSE = """{"manolo": "escobar"}"""

    def setUp(self):
        logger = Mock()
        self.routing = MapzenRouting('api_key', logger)
        self.url = MapzenRouting.PRODUCTION_ROUTING_BASE_URL

    def test_calculate_simple_routing_with_valid_params(self, req_mock):
        req_mock.register_uri('GET', requests_mock.ANY,
                              text=self.GOOD_RESPONSE_SIMPLE)
        origin = Coordinate('-120.2', '38.5')
        destination = Coordinate('-126.4', '43.2')
        waypoints = [origin, destination]
        response = self.routing.calculate_route_point_to_point(waypoints,
                                                               'car')

        self.assertEqual(response.shape, self.GOOD_SHAPE_SIMPLE)
        self.assertEqual(response.length, 444.59)
        self.assertEqual(response.duration, 16969)

    def test_uknown_mode_raise_exception(self, req_mock):
        req_mock.register_uri('GET', requests_mock.ANY,
                              text=self.GOOD_RESPONSE_SIMPLE)
        origin = Coordinate('-120.2', '38.5')
        destination = Coordinate('-126.4', '43.2')
        waypoints = [origin, destination]

        assert_raises(WrongParams,
                      self.routing.calculate_route_point_to_point,
                      waypoints, 'unknown')

    def test_calculate_routing_waypoints_with_valid_params(self, req_mock):
        req_mock.register_uri('GET', requests_mock.ANY,
                              text=self.GOOD_RESPONSE_MULTI)
        origin = Coordinate('-3.7', '40.4')
        pass_through = Coordinate('-3.4', '40.1')
        destination = Coordinate('-3.9', '40.6')
        waypoints = [origin, pass_through, destination]

        response = self.routing.calculate_route_point_to_point(waypoints,
                                                               'walk')

        self.assertEqual(response.length, 1.261)
        self.assertEqual(response.duration, 913)
        self.assertEqual(response.shape, self.GOOD_SHAPE_MULTI)
