#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import unittest
import requests_mock
from mock import Mock

from cartodb_services.google import GoogleMapsGeocoder
from cartodb_services.google.exceptions import MalformedResult, InvalidGoogleCredentials

requests_mock.Mocker.TEST_PREFIX = 'test_'


@requests_mock.Mocker()
class GoogleGeocoderTestCase(unittest.TestCase):
    GOOGLE_MAPS_GEOCODER_URL = 'https://maps.googleapis.com/maps/api/geocode/json'

    EMPTY_RESPONSE = """{
       "results" : [],
       "status" : "ZERO_RESULTS"
    }"""

    GOOD_RESPONSE = """{
       "results" : [
          {
             "address_components" : [
                {
                   "long_name" : "1600",
                   "short_name" : "1600",
                   "types" : [ "street_number" ]
                },
                {
                   "long_name" : "Amphitheatre Pkwy",
                   "short_name" : "Amphitheatre Pkwy",
                   "types" : [ "route" ]
                },
                {
                   "long_name" : "Mountain View",
                   "short_name" : "Mountain View",
                   "types" : [ "locality", "political" ]
                },
                {
                   "long_name" : "Santa Clara County",
                   "short_name" : "Santa Clara County",
                   "types" : [ "administrative_area_level_2", "political" ]
                },
                {
                   "long_name" : "California",
                   "short_name" : "CA",
                   "types" : [ "administrative_area_level_1", "political" ]
                },
                {
                   "long_name" : "United States",
                   "short_name" : "US",
                   "types" : [ "country", "political" ]
                },
                {
                   "long_name" : "94043",
                   "short_name" : "94043",
                   "types" : [ "postal_code" ]
                }
             ],
             "formatted_address" : "1600 Amphitheatre Parkway, Mountain View, CA 94043, USA",
             "geometry" : {
                "location" : {
                   "lat" : 37.4224764,
                   "lng" : -122.0842499
                },
                "location_type" : "ROOFTOP",
                "viewport" : {
                   "northeast" : {
                      "lat" : 37.4238253802915,
                      "lng" : -122.0829009197085
                   },
                   "southwest" : {
                      "lat" : 37.4211274197085,
                      "lng" : -122.0855988802915
                   }
                }
             },
             "place_id" : "ChIJ2eUgeAK6j4ARbn5u_wAGqWA",
             "types" : [ "street_address" ]
          }
       ],
       "status" : "OK"
    }"""

    MALFORMED_RESPONSE = """{"manolo": "escobar"}"""

    def setUp(self):
        logger = Mock()
        self.geocoder = GoogleMapsGeocoder('dummy_client_id',
                                           'MgxyOFxjZXIyOGO52jJlMzEzY1Oqy4hsO49E',
                                           logger)

    def test_geocode_address_with_valid_params(self, req_mock):
        req_mock.register_uri('GET', self.GOOGLE_MAPS_GEOCODER_URL,
                       text=self.GOOD_RESPONSE)
        response = self.geocoder.geocode(
            searchtext='Calle Eloy Gonzalo 27',
            city='Madrid',
            country='España')

        self.assertEqual(response[0], -122.0842499)
        self.assertEqual(response[1], 37.4224764)

    def test_geocode_address_empty_response(self, req_mock):
        req_mock.register_uri('GET', self.GOOGLE_MAPS_GEOCODER_URL,
                       text=self.EMPTY_RESPONSE)
        result = self.geocoder.geocode(searchtext='lkajfñlasjfñ')
        self.assertEqual(result, [])

    def test_geocode_with_malformed_result(self, req_mock):
        req_mock.register_uri('GET', self.GOOGLE_MAPS_GEOCODER_URL,
                       text=self.MALFORMED_RESPONSE)
        with self.assertRaises(MalformedResult):
            self.geocoder.geocode(
                searchtext='Calle Eloy Gonzalo 27',
                city='Madrid',
                country='España')

    def test_invalid_credentials(self, req_mock):
        with self.assertRaises(InvalidGoogleCredentials):
            GoogleMapsGeocoder('another_dummy_client_id',
                               'lalala',
                               None)
