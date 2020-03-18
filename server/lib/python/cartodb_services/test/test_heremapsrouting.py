#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import unittest
import requests_mock
from mock import Mock
from urlparse import urlparse, parse_qs

from cartodb_services.here import HereMapsRoutingIsoline
from cartodb_services.here.exceptions import BadGeocodingParams
from cartodb_services.here.exceptions import NoGeocodingParams
from cartodb_services.here.exceptions import MalformedResult

requests_mock.Mocker.TEST_PREFIX = 'test_'


@requests_mock.Mocker()
class HereMapsRoutingIsolineTestCase(unittest.TestCase):
    EMPTY_RESPONSE = """{
      "response": {
        "metaInfo": {
          "timestamp": "2016-02-10T10:42:21Z",
          "mapVersion": "8.30.61.107",
          "moduleVersion": "7.2.65.0-1222",
          "interfaceVersion": "2.6.20"
        },
        "center": {
          "latitude": 33,
          "longitude": 0.9999999
        },
        "isoline": [
          {
            "range": 1000,
            "component": [
              {
                "id": 0,
                "shape": []
              }
            ]
          }
        ],
        "start": {
          "linkId": "+1025046831",
          "mappedPosition": {
            "latitude": 32.968725,
            "longitude": 0.9993629
          },
          "originalPosition": {
            "latitude": 33,
            "longitude": 0.9999999
          }
        }
      }
    }"""

    ERROR_RESPONSE = """{
      "_type": "ns2:RoutingServiceErrorType",
      "type": "ApplicationError",
      "subtype": "InitIsolineSearchFailed",
      "details": "Error is NGEO_ERROR_UNKNOWN",
      "additionalData": [
        {
          "key": "error_code",
          "value": "NGEO_ERROR_UNKNOWN"
        }
      ],
      "metaInfo": {
        "timestamp": "2016-02-10T10:39:35Z",
        "mapVersion": "8.30.61.107",
        "moduleVersion": "7.2.65.0-1222",
        "interfaceVersion": "2.6.20"
      }
    }"""

    GOOD_RESPONSE = """{
      "response": {
        "metaInfo": {
          "timestamp": "2016-02-10T10:42:21Z",
          "mapVersion": "8.30.61.107",
          "moduleVersion": "7.2.65.0-1222",
          "interfaceVersion": "2.6.20"
        },
        "center": {
          "latitude": 33,
          "longitude": 0.9999999
        },
        "isoline": [
          {
            "range": 1000,
            "component": [
              {
                "id": 0,
                "shape": [
                  "32.9699707,0.9462833",
                  "32.9699707,0.9458542",
                  "32.9699707,0.9462833"
                ]
              }
            ]
          }, {
            "range": 2000,
            "component": [
              {
                "id": 0,
                "shape": [
                  "32.9699707,0.9462833",
                  "32.9699707,0.9750366",
                  "32.9699707,0.9462833"
                ]
              }
            ]
          }
        ],
        "start": {
          "linkId": "+1025046831",
          "mappedPosition": {
            "latitude": 32.968725,
            "longitude": 0.9993629
          },
          "originalPosition": {
            "latitude": 33,
            "longitude": 0.9999999
          }
        }
      }
    }"""

    MALFORMED_RESPONSE = """{"manolo": "escobar"}"""

    def setUp(self):
        self.logger = Mock()
        self.routing = HereMapsRoutingIsoline(None, None, self.logger)
        self.isoline_url = "{0}{1}".format(HereMapsRoutingIsoline.PRODUCTION_ROUTING_BASE_URL,
                                     HereMapsRoutingIsoline.ISOLINE_PATH)


    def test_calculate_isodistance_with_valid_params(self, req_mock):
        url = "{0}?start=geo%2133.0%2C1.0&mode=shortest%3Bcar".format(self.isoline_url)
        req_mock.register_uri('GET', url, text=self.GOOD_RESPONSE)
        response = self.routing.calculate_isodistance('geo!33.0,1.0', 'car',
                                                      ['1000', '2000'])
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['range'], 1000)
        self.assertEqual(response[1]['range'], 2000)
        self.assertEqual(response[0]['geom'], [u'32.9699707,0.9462833',
                                               u'32.9699707,0.9458542',
                                               u'32.9699707,0.9462833'])
        self.assertEqual(response[1]['geom'], [u'32.9699707,0.9462833',
                                               u'32.9699707,0.9750366',
                                               u'32.9699707,0.9462833'])

    def test_calculate_isochrone_with_valid_params(self, req_mock):
        url = "{0}?start=geo%2133.0%2C1.0&mode=shortest%3Bcar".format(self.isoline_url)
        req_mock.register_uri('GET', url, text=self.GOOD_RESPONSE)
        response = self.routing.calculate_isochrone('geo!33.0,1.0', 'car',
                                                    ['1000', '2000'])
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['range'], 1000)
        self.assertEqual(response[1]['range'], 2000)
        self.assertEqual(response[0]['geom'], [u'32.9699707,0.9462833',
                                               u'32.9699707,0.9458542',
                                               u'32.9699707,0.9462833'])
        self.assertEqual(response[1]['geom'], [u'32.9699707,0.9462833',
                                               u'32.9699707,0.9750366',
                                               u'32.9699707,0.9462833'])

    def test_calculate_isolines_empty_response(self, req_mock):
        url = "{0}?start=geo%2133.0%2C1.0&mode=shortest%3Bcar".format(
            self.isoline_url)
        req_mock.register_uri('GET', url, text=self.EMPTY_RESPONSE)
        response = self.routing.calculate_isochrone('geo!33.0,1.0', 'car',
                                                    ['1000', '2000'])
        self.assertEqual(len(response), 1)
        self.assertEqual(response[0]['range'], 1000)
        self.assertEqual(response[0]['geom'], [])

    def test_non_listed_parameters_filter_works_properly(self, req_mock):
        url = "{0}?start=geo%2133.0%2C1.0&mode=shortest%3Bcar".format(
            self.isoline_url)
        req_mock.register_uri('GET', url, text=self.GOOD_RESPONSE)
        response = self.routing.calculate_isochrone('geo!33.0,1.0', 'car',
                                                    ['1000', '2000'],
                                                    ['singlecomponent=true',
                                                     'resolution=3',
                                                     'maxpoints=1000',
                                                     'quality=2',
                                                     'false_option=true'])
        parsed_url = urlparse(req_mock.request_history[0].url)
        url_params = parse_qs(parsed_url.query)
        self.assertEqual(len(url_params), 8)
        self.assertEqual('false_option' in url_params, False)

    def test_mode_parameters_works_properly(self, req_mock):
        req_mock.register_uri('GET', requests_mock.ANY,
                              text=self.GOOD_RESPONSE)
        response = self.routing.calculate_isochrone('geo!33.0,1.0', 'car',
                                                    ['1000', '2000'],
                                                    ['mode_type=fastest',
                                                     'mode_feature=motorway',
                                                     'mode_feature_weight=-1',
                                                     'mode_traffic=false'])
        parsed_url = urlparse(req_mock.request_history[0].url)
        url_params = parse_qs(parsed_url.query)
        self.assertEqual(url_params['mode'][0],
                         'fastest;car;traffic:false;motorway:-1')

    def test_source_parameters_works_properly(self, req_mock):
        req_mock.register_uri('GET', requests_mock.ANY,
                              text=self.GOOD_RESPONSE)
        response = self.routing.calculate_isochrone('geo!33.0,1.0', 'car',
                                                    ['1000', '2000'],
                                                    ['is_destination=false'])
        parsed_url = urlparse(req_mock.request_history[0].url)
        url_params = parse_qs(parsed_url.query)

        self.assertEqual(url_params['start'][0], 'geo!33.0,1.0')

    def test_destination_parameters_works_properly(self, req_mock):
        req_mock.register_uri('GET', requests_mock.ANY,
                              text=self.GOOD_RESPONSE)
        response = self.routing.calculate_isochrone('geo!33.0,1.0', 'car',
                                                    ['1000', '2000'],
                                                    ['is_destination=true'])
        parsed_url = urlparse(req_mock.request_history[0].url)
        url_params = parse_qs(parsed_url.query)

        self.assertEqual(url_params['destination'][0], 'geo!33.0,1.0')

    def test_isodistance_with_nonstandard_url(self, req_mock):
        base_url = 'http://nonstandard_base'
        url = "{0}{1}".format(base_url, HereMapsRoutingIsoline.ISOLINE_PATH)
        routing = HereMapsRoutingIsoline(None, None, Mock(), { 'base_url': base_url })
        req_mock.register_uri('GET', url, text=self.GOOD_RESPONSE)
        response = routing.calculate_isodistance('geo!33.0,1.0', 'car',
                                                      ['1000', '2000'])
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['range'], 1000)
        self.assertEqual(response[1]['range'], 2000)
        self.assertEqual(response[0]['geom'], [u'32.9699707,0.9462833',
                                               u'32.9699707,0.9458542',
                                               u'32.9699707,0.9462833'])
        self.assertEqual(response[1]['geom'], [u'32.9699707,0.9462833',
                                               u'32.9699707,0.9750366',
                                               u'32.9699707,0.9462833'])
