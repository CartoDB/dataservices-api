#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import unittest

from heremaps import heremapsgeocoder
from heremaps.heremapsexceptions import BadGeocodingParams
from heremaps.heremapsexceptions import EmptyGeocoderResponse
from heremaps.heremapsexceptions import NoGeocodingParams
from heremaps.heremapsexceptions import MalformedResult

from secrets import *

class GeocoderTestCase(unittest.TestCase):
    EMPTY_RESPONSE = {
        "Response":{
            "MetaInfo":{
                "Timestamp":"2015-11-04T16:31:57.273+0000"
            },
            "View":[]
        }
    }

    GOOD_RESPONSE = {
        "Response": {
            "MetaInfo": {
                "Timestamp":"2015-11-04T16:30:32.187+0000"
            },
            "View":[{
                "_type":"SearchResultsViewType",
                "ViewId":0,
                "Result":[{
                    "Relevance":0.89,
                    "MatchLevel":"street",
                    "MatchQuality":{
                        "City":1.0,
                        "Street":[1.0]
                    },
                    "Location":{
                        "LocationId":"NT_yyKB4r3mCWAX4voWgxPcuA",
                        "LocationType":"address",
                        "DisplayPosition":{
                            "Latitude":40.43433,
                            "Longitude":-3.70126
                        },
                        "NavigationPosition":[{
                            "Latitude":40.43433,
                            "Longitude":-3.70126
                        }],
                        "MapView":{
                            "TopLeft":{
                                "Latitude":40.43493,
                                "Longitude":-3.70404
                            },
                            "BottomRight":{
                                "Latitude":40.43373,
                                "Longitude":-3.69873
                            }
                        },
                        "Address":{
                            "Label":"Calle de Eloy Gonzalo, Madrid, España",
                            "Country":"ESP",
                            "State":"Comunidad de Madrid",
                            "County":"Madrid",
                            "City":"Madrid",
                            "District":"Trafalgar",
                            "Street":"Calle de Eloy Gonzalo",
                            "AdditionalData":[{
                                "value":"España",
                                "key":"CountryName"
                            },
                            {
                                "value":"Comunidad de Madrid",
                                "key":"StateName"
                            },
                            {
                                "value":"Madrid",
                                "key":"CountyName"
                            }]
                        }
                    }
                }]
            }]
        }
    }

    def setUp(self):
        self.geocoder = heremapsgeocoder.Geocoder(None, None)

    def test_geocode_address_with_valid_params(self):
        self.geocoder.perform_request = lambda x: self.GOOD_RESPONSE
        response = self.geocoder.geocode_address(
            searchtext='Calle Eloy Gonzalo 27',
            city='Madrid',
            country='España')

    def test_geocode_address_with_invalid_params(self):
        with self.assertRaises(BadGeocodingParams):
            self.geocoder.geocode_address(
                searchtext='Calle Eloy Gonzalo 27',
                manolo='escobar')

    def test_geocode_address_with_no_params(self):
        with self.assertRaises(NoGeocodingParams):
            self.geocoder.geocode_address()

    def test_geocode_address_empty_response(self):
        self.geocoder.perform_request = lambda x: self.EMPTY_RESPONSE
        with self.assertRaises(EmptyGeocoderResponse):
            self.geocoder.geocode_address(searchtext='lkajfñlasjfñ')

    def test_extract_lng_lat_from_result(self):
        result = self.GOOD_RESPONSE['Response']['View'][0]['Result'][0]
        coordinates = self.geocoder.extract_lng_lat_from_result(result)

        self.assertEqual(coordinates[0], -3.70126)
        self.assertEqual(coordinates[1], 40.43433)

    def test_extract_lng_lat_from_result_with_malformed_result(self):
        result = {'manolo':'escobar'}

        with self.assertRaises(MalformedResult):
            self.geocoder.extract_lng_lat_from_result(result)

if __name__ == '__main__':
    main()
