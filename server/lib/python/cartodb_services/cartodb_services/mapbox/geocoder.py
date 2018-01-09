'''
Python client for the Mapbox Geocoder service.
'''

import json
import requests
from mapbox import Geocoder
from cartodb_services.metrics import Traceable
from cartodb_services.tools.exceptions import ServiceException
from cartodb_services.tools.qps import qps_retry

GEOCODER_NAME = 'geocoder_name'
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

    def __init__(self, token, logger, service_params=None):
        service_params = service_params or {}
        self._token = token
        self._logger = logger
        self._geocoder_name = service_params.get(GEOCODER_NAME,
                                                 EPHEMERAL_GEOCODER)
        self._geocoder = Geocoder(access_token=self._token,
                                  name=self._geocoder_name)

    def _parse_geocoder_response(self, response):
        json_response = json.loads(response)

        if json_response:
            feature = json_response[ENTRY_FEATURES][0]

            return self._extract_lng_lat_from_feature(feature)
        else:
            return []

    def _extract_lng_lat_from_feature(self, feature):
        geometry = feature[ENTRY_GEOMETRY]
        if geometry[ENTRY_TYPE] == TYPE_POINT:
            location = geometry[ENTRY_COORDINATES]
        else:
            location = feature[ENTRY_CENTER]

        longitude = location[0]
        latitude = location[1]
        return [longitude, latitude]

    @qps_retry(qps=10)
    def geocode(self, searchtext, city=None, state_province=None,
                country=None):
        address = [searchtext]
        if city:
            address.append(city)
        if state_province:
            address.append(state_province)

        try:
            response = self._geocoder.forward(address=', '.join(address),
                                              country=country,
                                              limit=1)

            if response.status_code == requests.codes.ok:
                return self._parse_geocoder_response(response.text)
            elif response.status_code == requests.codes.bad_request:
                return []
            else:
                raise ServiceException(response.status_code, response)
        except requests.Timeout as te:
            # In case of timeout we want to stop the job because the server
            # could be down
            self._logger.error('Timeout connecting to Mapbox geocoding server',
                               te)
            raise ServiceException('Error geocoding {0} using Mapbox'.format(
                searchtext), None)
        except requests.ConnectionError as ce:
            # Don't raise the exception to continue with the geocoding job
            self._logger.error('Error connecting to Mapbox geocoding server',
                               exception=ce)
            return []
