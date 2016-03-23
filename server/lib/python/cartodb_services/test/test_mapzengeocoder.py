#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import unittest
import requests_mock

from cartodb_services.mapzen import MapzenGeocoder
from cartodb_services.mapzen.exceptions import MalformedResult

requests_mock.Mocker.TEST_PREFIX = 'test_'


@requests_mock.Mocker()
class GoogleGeocoderTestCase(unittest.TestCase):
    MAPZEN_GEOCODER_URL = 'https://search.mapzen.com/v1/search'

    EMPTY_RESPONSE = """{
       "results" : [],
       "status" : "ZERO_RESULTS"
    }"""

    GOOD_RESPONSE = """{
      "geocoding": {
        "version": "0.1",
        "attribution": "https://search.mapzen.com/v1/attribution",
        "query": {
          "text": "Calle siempreviva 3, Valladolid",
          "parsed_text": {
            "name": "Calle siempreviva 3",
            "regions": [
              "Calle siempreviva 3",
              "Valladolid"
            ],
            "admin_parts": "Valladolid"
          },
          "types": {
            "from_layers": [
              "osmaddress",
              "openaddresses"
            ]
          },
          "size": 10,
          "private": false,
          "type": [
            "osmaddress",
            "openaddresses"
          ],
          "querySize": 20
        },
        "engine": {
          "name": "Pelias",
          "author": "Mapzen",
          "version": "1.0"
        },
        "timestamp": 1458661873749
      },
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "properties": {
            "id": "df7428b955ae44a39dc40d52578f61e3",
            "gid": "oa:address:df7428b955ae44a39dc40d52578f61e3",
            "layer": "address",
            "source": "oa",
            "name": "5 Close Siempreviva",
            "housenumber": "5",
            "street": "Close Siempreviva",
            "country_a": "ESP",
            "country": "Spain",
            "region": "Valladolid",
            "localadmin": "Valladolid",
            "locality": "Valladolid",
            "confidence": 0.887,
            "label": "5 Close Siempreviva, Valladolid, Spain"
          },
          "geometry": {
            "type": "Point",
            "coordinates": [
              -4.730928,
              41.669034
            ]
          }
        }
      ]
    }"""

    MALFORMED_RESPONSE = """{"manolo": "escobar"}"""

    def setUp(self):
        self.geocoder = MapzenGeocoder('search-XXXXXXX')

    def test_geocode_address_with_valid_params(self, req_mock):
        req_mock.register_uri('GET', self.MAPZEN_GEOCODER_URL,
                       text=self.GOOD_RESPONSE)
        response = self.geocoder.geocode(
            searchtext='Calle Siempreviva 3, Valldolid',
            country='ESP')

        self.assertEqual(response[0], -4.730928)
        self.assertEqual(response[1], 41.669034)

    def test_geocode_with_malformed_result(self, req_mock):
        req_mock.register_uri('GET', self.MAPZEN_GEOCODER_URL,
                       text=self.MALFORMED_RESPONSE)
        with self.assertRaises(MalformedResult):
            self.geocoder.geocode(
                searchtext='Calle Siempreviva 3, Valladolid',
                country='ESP')
