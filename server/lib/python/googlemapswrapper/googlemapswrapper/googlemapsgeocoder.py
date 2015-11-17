#!/usr/local/bin/python
# -*- coding: utf-8 -*-

# client_id = config['client_id']
# client_secret = config['client_secret']

# gmaps = googlemaps.Client(client_id=client_id, client_secret=client_secret)

# arg = lambda x: (', ' + x) if x else ''

# query = searchtext + arg(city) + arg(state_province) + arg(country)

# geocode_result = gmaps.geocode(query)

# lng = geocode_result[0]['geometry']['location']['lng']
# lat = geocode_result[0]['geometry']['location']['lat']

# coordinates = [lng, lat]

import googlemaps

from googlemapswrapperexceptions import MalformedResult

class Geocoder:
    'A Google Maps Geocoder wrapper for python'

    client_id = ''
    client_secret = ''

    def __init__(self, client_id, client_secret):
        self.client_id = client_id
        self.client_secret = client_secret
        self.geocoder = googlemaps.Client(client_id=client_id, client_secret=client_secret)

    def geocode_address(self, searchtext, city=None, state_province=None, country=None):
        query = self._construct_query(searchtext, city, state_province, country)

        results = self.geocoder.geocode(query)

        return results if results else None

    def extract_lng_lat_from_result(self, result):
        try:
            location = result['geometry']['location']

            longitude = location['lng']
            latitude = location['lat']
        except KeyError:
            raise MalformedResult()

        return [longitude, latitude]

    def _construct_query(self, searchtext, city=None, state_province=None, country=None):
        arg = lambda x: (', ' + x) if x else ''

        query = searchtext + arg(city) + arg(state_province) + arg(country)

        return query