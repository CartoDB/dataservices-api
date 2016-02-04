#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import unittest
import requests_mock

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

    GOOD_RESPONSE = """{
        "Response": {
            "MetaInfo": {
                "Timestamp": "2015-11-04T16:30:32.187+0000"
            },
            "View": [{
                "_type": "SearchResultsViewType",
                "ViewId": 0,
                "Result": {
                    "Relevance": 0.89,
                    "MatchLevel": "street",
                    "MatchQuality": {
                        "City": 1.0,
                        "Street": [1.0]
                    },
                    "Location": {
                        "LocationId": "NT_yyKB4r3mCWAX4voWgxPcuA",
                        "LocationType": "address",
                        "DisplayPosition": {
                            "Latitude": 40.43433,
                            "Longitude": -3.70126
                        },
                        "NavigationPosition": [{
                            "Latitude": 40.43433,
                            "Longitude": -3.70126
                        }],
                        "MapView": {
                            "TopLeft": {
                                "Latitude": 40.43493,
                                "Longitude": -3.70404
                            },
                            "BottomRight": {
                                "Latitude": 40.43373,
                                "Longitude": -3.69873
                            }
                        },
                        "Address": {
                            "Label": "Calle de Eloy Gonzalo, Madrid, Espana",
                            "Country": "ESP",
                            "State": "Comunidad de Madrid",
                            "County": "Madrid",
                            "City": "Madrid",
                            "District": "Trafalgar",
                            "Street": "Calle de Eloy Gonzalo",
                            "AdditionalData": [{
                                "value": "Espana",
                                "key": "CountryName"
                            },
                            {
                                "value": "Comunidad de Madrid",
                                "key": "StateName"
                            },
                            {
                                "value": "Madrid",
                                "key": "CountyName"
                            }]
                        }
                    }
                }
            }]
        }
    }"""

    MALFORMED_RESPONSE = """{"manolo": "escobar"}"""

    def setUp(self):
        self.geocoder = HereMapsGeocoder(None, None)

    def test_geocode_address_with_valid_params(self, req_mock):
        req_mock.register_uri('GET', HereMapsGeocoder.PRODUCTION_GEOCODE_JSON_URL,
                       text=self.GOOD_RESPONSE)
        response = self.geocoder.geocode(
            searchtext='Calle Eloy Gonzalo 27',
            city='Madrid',
            country='España')

        self.assertEqual(response[0], -3.70126)
        self.assertEqual(response[1], 40.43433)

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
        with self.assertRaises(NoGeocodingParams):
            self.geocoder.geocode()

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
                searchtext='Calle Eloy Gonzalo 27',
                city='Madrid',
                country='España')
