#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import unittest

from heremaps import heremapsgeocoder
from heremaps.heremapsexceptions import BadGeocodingParams, EmptyGeocoderResponse, NoGeocodingParams

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

    def test_geocodeAddress_with_valid_params(self):
        self.geocoder.performRequest = lambda x: self.GOOD_RESPONSE
        response = self.geocoder.geocodeAddress(
            searchtext='Calle Eloy Gonzalo 27',
            city='Madrid',
            country='España')

    def test_geocodeAddress_with_invalid_params(self):
        with self.assertRaises(BadGeocodingParams):
            self.geocoder.geocodeAddress(
                searchtext='Calle Eloy Gonzalo 27',
                manolo='escobar')

    def test_geocodeAddress_with_no_params(self):
        with self.assertRaises(NoGeocodingParams):
            self.geocoder.geocodeAddress()

    def test_geocodeAddress_empty_response(self):
        self.geocoder.performRequest = lambda x: self.EMPTY_RESPONSE
        with self.assertRaises(EmptyGeocoderResponse):
            self.geocoder.geocodeAddress(searchtext='lkajfñlasjfñ')

if __name__ == '__main__':
    main()
