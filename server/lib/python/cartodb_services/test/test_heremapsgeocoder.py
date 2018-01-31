#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import unittest
import requests_mock
from mock import Mock

from cartodb_services.here import HereMapsGeocoder
from cartodb_services.here.exceptions import BadGeocodingParams
from cartodb_services.here.exceptions import NoGeocodingParams
from cartodb_services.here.exceptions import MalformedResult

requests_mock.Mocker.TEST_PREFIX = 'test_'


@requests_mock.Mocker()
class HereMapsGeocoderTestCase(unittest.TestCase):
    EMPTY_RESPONSE = """{
        "Response": {
            "MetaInfo": {
                "Timestamp": "2015-11-04T16:31:57.273+0000"
            },
            "View": []
        }
    }"""

    GOOD_RESPONSE = unicode("""{
      "Response": {
        "MetaInfo": {
          "Timestamp": "2016-02-10T14:17:33.792+0000",
          "NextPageInformation": "2"
        },
        "View": [
          {
            "_type": "SearchResultsViewType",
            "ViewId": 0,
            "Result": [
              {
                "Relevance": 1,
                "MatchLevel": "houseNumber",
                "MatchQuality": {
                  "Street": [
                    1
                  ],
                  "HouseNumber": 1
                },
                "MatchType": "pointAddress",
                "Location": {
                  "LocationId": "NT_CKopMSB9JnBYAO11CMOrxB_zUD",
                  "LocationType": "address",
                  "DisplayPosition": {
                    "Latitude": 37.70246,
                    "Longitude": -5.2794
                  },
                  "NavigationPosition": [
                    {
                      "Latitude": 37.7024199,
                      "Longitude": -5.27939
                    }
                  ],
                  "MapView": {
                    "TopLeft": {
                      "Latitude": 37.7035842,
                      "Longitude": -5.2808208
                    },
                    "BottomRight": {
                      "Latitude": 37.7013358,
                      "Longitude": -5.2779792
                    }
                  },
                  "Address": {
                    "Label": "Calle Amor de Dios, 35, 14700 Palma del Río (Córdoba), España",
                    "Country": "ESP",
                    "State": "Andalucía",
                    "County": "Córdoba",
                    "City": "Palma del Río",
                    "Street": "Calle Amor de Dios",
                    "HouseNumber": "35",
                    "PostalCode": "14700",
                    "AdditionalData": [
                      {
                        "value": "España",
                        "key": "CountryName"
                      },
                      {
                        "value": "Andalucía",
                        "key": "StateName"
                      },
                      {
                        "value": "Córdoba",
                        "key": "CountyName"
                      }
                    ]
                  }
                }
              }
            ]
          }
        ]
      }
    }""", 'utf-8')

    MALFORMED_RESPONSE = """{"manolo": "escobar"}"""

    def setUp(self):
        logger = Mock()
        self.geocoder = HereMapsGeocoder(None, None, logger)

    def test_geocode_address_with_valid_params(self, req_mock):
        req_mock.register_uri('GET', HereMapsGeocoder.PRODUCTION_GEOCODE_JSON_URL,
                       text=self.GOOD_RESPONSE)
        response = self.geocoder.geocode(
            searchtext='Calle amor de dios',
            city='Cordoba',
            country='España')

        self.assertEqual(response[0], -5.2794)
        self.assertEqual(response[1], 37.70246)

    def test_geocode_address_with_invalid_params(self, req_mock):
        req_mock.register_uri('GET', HereMapsGeocoder.PRODUCTION_GEOCODE_JSON_URL,
                       text=self.GOOD_RESPONSE)
        with self.assertRaises(BadGeocodingParams):
            self.geocoder.geocode(
                searchtext='Calle Eloy Gonzalo 27',
                manolo='escobar')

    def test_geocode_address_with_no_params(self, req_mock):
        req_mock.register_uri('GET', HereMapsGeocoder.PRODUCTION_GEOCODE_JSON_URL,
                       text=self.GOOD_RESPONSE)
        result = self.geocoder.geocode()
        self.assertEqual(result, [])

    def test_geocode_address_with_non_empty_string_params(self, req_mock):
        req_mock.register_uri('GET', HereMapsGeocoder.PRODUCTION_GEOCODE_JSON_URL,
                       text=self.GOOD_RESPONSE)
        result = self.geocoder.geocode(searchtext=" ", city=None, state=" ", country=" ")
        self.assertEqual(result, [])

    def test_geocode_address_empty_response(self, req_mock):
        req_mock.register_uri('GET', HereMapsGeocoder.PRODUCTION_GEOCODE_JSON_URL,
                       text=self.EMPTY_RESPONSE)
        result = self.geocoder.geocode(searchtext='lkajfñlasjfñ')
        self.assertEqual(result, [])

    def test_geocode_with_malformed_result(self, req_mock):
        req_mock.register_uri('GET', HereMapsGeocoder.PRODUCTION_GEOCODE_JSON_URL,
                       text=self.MALFORMED_RESPONSE)
        with self.assertRaises(MalformedResult):
            self.geocoder.geocode(
                searchtext='Calle amor de dios',
                city='Cordoba',
                country='España')

    def test_geocode_with_nonstandard_url(self, req_mock):
        geocoder = HereMapsGeocoder(None, None, Mock(), { 'json_url': 'http://nonstandard_here_url' })
        req_mock.register_uri('GET', 'http://nonstandard_here_url', text=self.GOOD_RESPONSE)
        response = geocoder.geocode(
            searchtext='Calle amor de dios',
            city='Cordoba',
            country='España')

        self.assertEqual(response[0], -5.2794)
        self.assertEqual(response[1], 37.70246)



