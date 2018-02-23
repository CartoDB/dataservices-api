'''
Python implementation for TomTom services based isolines.
'''

import json
import requests
from uritemplate import URITemplate

from cartodb_services.tools.exceptions import ServiceException
from cartodb_services.tools.qps import qps_retry
from cartodb_services.tools import Coordinate
from types import (DEFAULT_PROFILE, VALID_PROFILES, DEFAULT_DEPARTAT,
                   MAX_SPEEDS)

BASEURI = ('https://api.tomtom.com/routing/1/calculateReachableRange/'
           '{origin}'
           '/json'
           '?key={apikey}'
           '&timeBudgetInSec={time}'
           '&travelMode={travelmode}'
           '&departAt={departat}')

ENTRY_REACHABLERANGE = 'reachableRange'
ENTRY_BOUNDARY = 'boundary'
ENTRY_LATITUDE = 'latitude'
ENTRY_LONGITUDE = 'longitude'


class TomTomIsolines():
    '''
    Python wrapper for TomTom services based isolines.
    '''

    def __init__(self, apikey, logger, service_params=None):
        service_params = service_params or {}
        self._apikey = apikey
        self._logger = logger

    def _uri(self, origin, time_range, profile=DEFAULT_PROFILE,
             date_time=DEFAULT_DEPARTAT):
        uri = URITemplate(BASEURI).expand(apikey=self._apikey,
                                          origin=origin,
                                          time=time_range,
                                          travelmode=profile,
                                          departat=date_time)
        return uri

    def _validate_profile(self, profile):
        if profile not in VALID_PROFILES:
            raise ValueError('{profile} is not a valid profile. '
                             'Valid profiles are: {valid_profiles}'.format(
                                 profile=profile,
                                 valid_profiles=', '.join(
                                     [x for x in VALID_PROFILES])))

    def _parse_coordinates(self, boundary):
        return [Coordinate(c[ENTRY_LONGITUDE], c[ENTRY_LONGITUDE]) for c in boundary]

    def _parse_reachablerange_response(self, response):
        json_response = json.loads(response)

        if json_response:
            reachable_range = json_response[ENTRY_REACHABLERANGE]

            return self._parse_coordinates(reachable_range[ENTRY_BOUNDARY])

    @qps_retry(qps=5)
    def _calculate_isoline(self, origin, time_range,
                           profile=DEFAULT_PROFILE,
                           date_time=DEFAULT_DEPARTAT):
        origin = '{lat},{lon}'.format(lat=origin.latitude,
                                      lon=origin.longitude)

        uri = self._uri(origin, time_range, profile, date_time)
        try:
            response = requests.get(uri)

            if response.status_code == requests.codes.ok:
                return self._parse_reachablerange_response(response.text)
            elif response.status_code == requests.codes.bad_request:
                return []
            elif response.status_code == requests.codes.unprocessable_entity:
                return []
            else:
                raise ServiceException(response.status_code, response)
        except requests.Timeout as te:
            # In case of timeout we want to stop the job because the server
            # could be down
            self._logger.error('Timeout connecting to TomTom calculateReachableRange service',
                               te)
            raise ServiceException('Error getting calculateReachableRange data from TomTom',
                                   None)
        except requests.ConnectionError as ce:
            # Don't raise the exception to continue with the geocoding job
            self._logger.error('Error connecting to TomTom calculateReachableRange service',
                               exception=ce)
            return []

    def calculate_isochrone(self, origin, time_ranges,
                            profile=DEFAULT_PROFILE,
                            date_time=DEFAULT_DEPARTAT):
        self._validate_profile(profile)

        isochrones = []
        for time_range in time_ranges:
            coordinates = self._calculate_isoline(origin=origin,
                                                  time_range=time_range,
                                                  profile=profile,
                                                  date_time=date_time)

            isochrones.append(TomTomIsochronesResponse(coordinates,
                                                       time_range))
        return isochrones

    def calculate_isodistance(self, origin, distance_range,
                              profile=DEFAULT_PROFILE,
                              date_time=DEFAULT_DEPARTAT):
        self._validate_profile(profile)

        max_speed = MAX_SPEEDS[profile]
        time_range = distance_range / max_speed

        return self._calculate_isoline(origin=origin,
                                       time_range=time_range,
                                       profile=profile,
                                       date_time=date_time)


class TomTomIsochronesResponse:

    def __init__(self, coordinates, duration):
        self._coordinates = coordinates
        self._duration = duration

    @property
    def coordinates(self):
        return self._coordinates

    @property
    def duration(self):
        return self._duration
