'''
Python client for the Mapbox Geocoder service.
'''

import json
import requests
from mapbox import Geocoder
from cartodb_services.metrics import Traceable
from cartodb_services.mapbox.exceptions import ServiceException

ACCESS_TOKEN = 'pk.eyJ1IjoiYWNhcmxvbiIsImEiOiJjamJuZjQ1Zjc0Ymt4Mnh0YmFrMmhtYnY4In0.gt9cw0VeKc3rM2mV5pcEmg'

EPHEMERAL_GEOCODER = 'mapbox.places'
PERMANENT_GEOCODER = 'mapbox.places-permanent'
DEFAULT_GEOCODER = EPHEMERAL_GEOCODER

ENTRY_FEATURES = 'features'
ENTRY_CENTER = 'center'
ENTRY_GEOMETRY = 'geometry'
ENTRY_COORDINATES = 'coordinates'
ENTRY_TYPE = 'type'
TYPE_POINT = 'Point'


class MapboxGeocoder(Traceable):
    '''
    Python wrapper for the Mapbox Geocoder service.
    '''

    def __init__(self, token=ACCESS_TOKEN, name=DEFAULT_GEOCODER):
        self._token = token
        self._geocoder = Geocoder(access_token=self._token, name=name)

    def _parse_geocoder_response(self, response):
        json_response = json.loads(response)
        feature = json_response[ENTRY_FEATURES][0]

        return self._extract_lng_lat_from_feature(feature)

    def _extract_lng_lat_from_feature(self, feature):
        geometry = feature[ENTRY_GEOMETRY]
        if geometry[ENTRY_TYPE] == TYPE_POINT:
            location = geometry[ENTRY_COORDINATES]
        else:
            location = feature[ENTRY_CENTER]

        longitude = location[0]
        latitude = location[1]
        return [longitude, latitude]

    def geocode(self, address, country=None):
        response = self._geocoder.forward(address=address,
                                          country=country,
                                          limit=1)

        if response.status_code == requests.codes.ok:
            return self._parse_geocoder_response(response.text)
        else:
            raise ServiceException(response.status_code, response.content)
