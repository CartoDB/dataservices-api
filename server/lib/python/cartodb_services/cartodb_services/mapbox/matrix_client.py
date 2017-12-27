'''
Python client for the Mapbox Time Matrix service.
'''

import requests
from cartodb_services.metrics import Traceable
from cartodb_services.tools.coordinates import (validate_coordinates,
                                                marshall_coordinates)
from exceptions import ServiceException

ACCESS_TOKEN = 'pk.eyJ1IjoiYWNhcmxvbiIsImEiOiJjamJuZjQ1Zjc0Ymt4Mnh0YmFrMmhtYnY4In0.gt9cw0VeKc3rM2mV5pcEmg'

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

    def __init__(self, token=ACCESS_TOKEN):
        self.token = token

    def _uri(self, coordinates, profile=DEFAULT_PROFILE):
        return BASEURI.format(profile=profile, coordinates=coordinates,
                              token=self.token)

    def _parse_matrix_response(self, response):
        return response

    def matrix(self, coordinates, profile=DEFAULT_PROFILE):
        validate_profile(profile)
        validate_coordinates(coordinates,
                             NUM_COORDINATES_MIN, NUM_COORDINATES_MAX)

        coords = marshall_coordinates(coordinates)

        uri = self._uri(coords, profile)
        response = requests.get(uri)

        if response.status_code == requests.codes.ok:
            return self._parse_matrix_response(response.text)
        else:
            raise ServiceException(response.status_code, response.content)
