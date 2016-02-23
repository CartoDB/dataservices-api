#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import unittest
import requests_mock
import re
from nose.tools import assert_raises
from urlparse import urlparse, parse_qs

from cartodb_services.mapzen import MapzenRouting, MapzenRoutingResponse
from cartodb_services.mapzen.exceptions import WrongParams
from cartodb_services.tools import Coordinate

requests_mock.Mocker.TEST_PREFIX = 'test_'


@requests_mock.Mocker()
class MapzenRoutingTestCase(unittest.TestCase):

    GOOD_SHAPE = [(38.5, -120.2), (43.2, -126.4)]

    GOOD_RESPONSE = """{{
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
    }}""".format(GOOD_SHAPE)

    MALFORMED_RESPONSE = """{"manolo": "escobar"}"""

    def setUp(self):
        self.routing = MapzenRouting('api_key')
        self.url = MapzenRouting.PRODUCTION_ROUTING_BASE_URL

    def test_calculate_simple_routing_with_valid_params(self, req_mock):
        req_mock.register_uri('GET', requests_mock.ANY, text=self.GOOD_RESPONSE)
        origin = Coordinate('-120.2','38.5')
        destination = Coordinate('-126.4','43.2')
        response = self.routing.calculate_route_point_to_point(origin, destination,'car')

        self.assertEqual(response.shape, self.GOOD_SHAPE)
        self.assertEqual(response.length, 444.59)
        self.assertEqual(response.duration, 16969)

    def test_uknown_mode_raise_exception(self, req_mock):
        req_mock.register_uri('GET', requests_mock.ANY, text=self.GOOD_RESPONSE)
        origin = Coordinate('-120.2','38.5')
        destination = Coordinate('-126.4','43.2')

        assert_raises(WrongParams, self.routing.calculate_route_point_to_point, origin, destination, 'unknown')
