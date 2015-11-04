#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import json
import urllib

from heremapsexceptions import BadGeocodingParams, EmptyGeocoderResponse, NoGeocodingParams

class Geocoder:
    'A Here Maps Geocoder wrapper for python'

    URL_GEOCODE_JSON = 'http://geocoder.api.here.com/6.2/geocode.json'
    DEFAULT_MAXRESULTS = 1

    ADDRESS_PARAMS = [
        'city',
        'country',
        'county',
        'district',
        'housenumber',
        'postalcode',
        'searchtext',
        'state',
        'street'
        ]

    ADMITTED_PARAMS = [
        'additionaldata',
        'app_id',
        'app_code',
        'bbox',
        'countryfocus',
        'gen',
        'jsonattributes',
        'jsoncallback',
        'language',
        'locationattributes',
        'locationid',
        'mapview',
        'maxresults',
        'pageinformation',
        'politicalview',
        'prox',
        'strictlanguagemode'
        ] + ADDRESS_PARAMS

    app_id = ''
    app_code = ''
    maxresults = ''

    def __init__(self, app_id, app_code, maxresults=DEFAULT_MAXRESULTS):
        self.app_id = app_id
        self.app_code = app_code
        self.maxresults = maxresults

    def geocode(self, params):
        if not set(params.keys()).issubset(set(self.ADDRESS_PARAMS)):
            raise BadGeocodingParams(params)

        response = self.performRequest(params)

        try:
            results = response['Response']['View'][0]['Result']
        except IndexError:
            raise EmptyGeocoderResponse()

        return results

    def performRequest(self, params):
        request_params = {
            'app_id' : self.app_id,
            'app_code' : self.app_code,
            'maxresults' : self.maxresults,
            'gen' : '9'
            }
        request_params.update(params)

        encoded_request_params = urllib.urlencode(request_params)

        response = json.load(
            urllib.urlopen(self.URL_GEOCODE_JSON
                + '?'
                + encoded_request_params))

        return response

    def geocodeAddress(self, **kwargs):
        params = {}
        for key, value in kwargs.iteritems():
            if value: params[key] = value

        if not params: raise NoGeocodingParams()

        return self.geocode(params)

    def extractLngLatFromResult(self, result):
        location = result['Location']

        longitude = location['DisplayPosition']['Longitude']
        latitude = location['DisplayPosition']['Latitude']

        return [longitude, latitude]
