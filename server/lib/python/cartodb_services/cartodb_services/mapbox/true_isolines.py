import json
import requests
from uritemplate import URITemplate

from cartodb_services.tools.exceptions import ServiceException
from cartodb_services.tools.qps import qps_retry
from cartodb_services.tools import Coordinate

BASEURI = ('https://api.mapbox.com/isochrone/v1/mapbox/{profile}/{coordinates}?contours_minutes={contours_minutes}&access_token={apikey}')

PROFILE_DRIVING = 'driving'
PROFILE_CYCLING = 'cycling'
PROFILE_WALKING = 'walking'
DEFAULT_PROFILE = PROFILE_DRIVING

MAX_SPEEDS = {
    PROFILE_WALKING: 3.3333333,  # In m/s, assuming 12km/h walking speed
    PROFILE_CYCLING: 16.67,  # In m/s, assuming 60km/h max speed
    PROFILE_DRIVING: 41.67  # In m/s, assuming 140km/h max speed
}

VALID_PROFILES = [PROFILE_DRIVING,
                  PROFILE_CYCLING,
                  PROFILE_WALKING]

ENTRY_FEATURES = 'features'
ENTRY_GEOMETRY = 'geometry'


class MapboxTrueIsolines():
    '''
    Python wrapper for Mapbox based isolines.
    '''

    def __init__(self, apikey, logger, service_params=None):
        service_params = service_params or {}
        self._apikey = apikey
        self._logger = logger

    def _uri(self, origin, time_range, profile=DEFAULT_PROFILE):
        uri = URITemplate(BASEURI).expand(apikey=self._apikey,
                                          coordinates=origin,
                                          contours_minutes=time_range,
                                          profile=profile)
        return uri

    def _validate_profile(self, profile):
        if profile not in VALID_PROFILES:
            raise ValueError('{profile} is not a valid profile. '
                             'Valid profiles are: {valid_profiles}'.format(
                                 profile=profile,
                                 valid_profiles=', '.join(
                                     [x for x in VALID_PROFILES])))

    def _parse_coordinates(self, boundary):
        return [Coordinate(c[0], c[1]) for c in boundary]

    def _parse_isochrone_service(self, response):
        json_response = json.loads(response)

        coordinates = []
        if json_response:
            for feature in json_response[ENTRY_FEATURES]:
                geometry = feature[ENTRY_GEOMETRY]
                coordinates.append(self._parse_coordinates(geometry))

        return coordinates

    @qps_retry(qps=5, provider='mapbox_iso')
    def _calculate_isoline(self, origin, time_ranges,
                           profile=DEFAULT_PROFILE):
        origin = '{lon},{lat}'.format(lat=origin.latitude,
                                      lon=origin.longitude)

        time_ranges.sort()
        time_ranges_seconds = ','.join([str(round(t/60)) for t in time_ranges])

        uri = self._uri(origin, time_ranges_seconds, profile)

        try:
            response = requests.get(uri)

            if response.status_code == requests.codes.ok:
                isolines = []

                coordinates = self._parse_isochrone_service(response.text)
                for t, c in zip(time_ranges, coordinates):
                    isolines.append(MapboxTrueIsochronesResponse(c, t))

                return isolines
            elif response.status_code == requests.codes.bad_request:
                return []
            elif response.status_code == requests.codes.unprocessable_entity:
                return []
            else:
                raise ServiceException(response.status_code, response)
        except requests.Timeout as te:
            # In case of timeout we want to stop the job because the server
            # could be down
            self._logger.error('Timeout connecting to Mapbox isochrone service',
                               te)
            raise ServiceException('Error getting isochrone data from Mapbox',
                                   None)
        except requests.ConnectionError as ce:
            # Don't raise the exception to continue with the geocoding job
            self._logger.error('Error connecting to Mapbox isochrone service',
                               exception=ce)
            return []

    def calculate_isochrone(self, origin, time_ranges,
                            profile=DEFAULT_PROFILE):
        self._validate_profile(profile)

        return self._calculate_isoline(origin=origin,
                                       time_ranges=time_ranges,
                                       profile=profile)

    def calculate_isodistance(self, origin, distance_range,
                              profile=DEFAULT_PROFILE):
        self._validate_profile(profile)

        max_speed = MAX_SPEEDS[profile]
        time_range = distance_range / max_speed

        return self._calculate_isoline(origin=origin,
                                       time_ranges=[time_range],
                                       profile=profile)[0].coordinates


class MapboxTrueIsochronesResponse:

    def __init__(self, coordinates, duration):
        self._coordinates = coordinates
        self._duration = duration

    @property
    def coordinates(self):
        return self._coordinates

    @property
    def duration(self):
        return self._duration
