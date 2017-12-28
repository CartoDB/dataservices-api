'''
Python client for the Mapbox Time Matrix service.
'''

import requests
from cartodb_services.metrics import Traceable
from cartodb_services.tools.coordinates import (validate_coordinates,
                                                marshall_coordinates)
from exceptions import ServiceException
from cartodb_services.tools.qps import qps_retry

BASEURI = ('https://api.mapbox.com/directions-matrix/v1/mapbox/{profile}/'
           '{coordinates}'
           '?access_token={token}'
           '&sources=0'  # Set the first coordinate as source...
           '&destinations=all')  # ...and the rest as destinations

NUM_COORDINATES_MIN = 2  # https://www.mapbox.com/api-documentation/#matrix
NUM_COORDINATES_MAX = 25  # https://www.mapbox.com/api-documentation/#matrix

PROFILE_DRIVING_TRAFFIC = 'driving-traffic'
PROFILE_DRIVING = 'driving'
PROFILE_CYCLING = 'cycling'
PROFILE_WALKING = 'walking'
DEFAULT_PROFILE = PROFILE_DRIVING

VALID_PROFILES = [PROFILE_DRIVING_TRAFFIC,
                  PROFILE_DRIVING,
                  PROFILE_CYCLING,
                  PROFILE_WALKING]

ENTRY_DURATIONS = 'durations'


def validate_profile(profile):
    if profile not in VALID_PROFILES:
        raise ValueError('{profile} is not a valid profile. '
                         'Valid profiles are: {valid_profiles}'.format(
                             profile=profile,
                             valid_profiles=', '.join(
                                 [x for x in VALID_PROFILES])))


class MapboxMatrixClient(Traceable):
    '''
    Python wrapper for the Mapbox Time Matrix service.
    '''

    def __init__(self, token, logger, service_params=None):
        service_params = service_params or {}
        self._token = token
        self._logger = logger

    def _uri(self, coordinates, profile=DEFAULT_PROFILE):
        return BASEURI.format(profile=profile, coordinates=coordinates,
                              token=self._token)

    @qps_retry(qps=1)
    def matrix(self, coordinates, profile=DEFAULT_PROFILE):
        validate_profile(profile)
        validate_coordinates(coordinates,
                             NUM_COORDINATES_MIN, NUM_COORDINATES_MAX)

        coords = marshall_coordinates(coordinates)

        uri = self._uri(coords, profile)
        response = requests.get(uri)

        if response.status_code == requests.codes.ok:
            return response.text
        else:
            raise ServiceException(response.status_code, response.content)
