'''
Python implementation for Mapbox services based isolines.
Uses the Mapbox Time Matrix service.
'''

import json
from cartodb_services.tools.spherical import (get_angles,
                                              calculate_dest_location)
from cartodb_services.mapbox.matrix_client import (validate_profile,
                                                   DEFAULT_PROFILE,
                                                   PROFILE_WALKING,
                                                   PROFILE_DRIVING,
                                                   PROFILE_CYCLING,
                                                   ENTRY_DURATIONS)

MAX_SPEEDS = {
    PROFILE_WALKING: 3.3333333,  # In m/s, assuming 12km/h walking speed
    PROFILE_CYCLING: 16.67,  # In m/s, assuming 60km/h max speed
    PROFILE_DRIVING: 41.67  # In m/s, assuming 140km/h max speed
}

DEFAULT_NUM_ANGLES = 24
DEFAULT_MAX_ITERS = 5
DEFAULT_TOLERANCE = 0.1

MATRIX_NUM_ANGLES = DEFAULT_NUM_ANGLES
MATRIX_MAX_ITERS = DEFAULT_MAX_ITERS
MATRIX_TOLERANCE = DEFAULT_TOLERANCE

UNIT_FACTOR_ISOCHRONE = 1.0
UNIT_FACTOR_ISODISTANCE = 1000.0
DEFAULT_UNIT_FACTOR = UNIT_FACTOR_ISOCHRONE


class MapboxIsolines():
    '''
    Python wrapper for Mapbox services based isolines.
    '''

    def __init__(self, matrix_client, logger, service_params=None):
        service_params = service_params or {}
        self._matrix_client = matrix_client
        self._logger = logger

    def _calculate_matrix_cost(self, origin, targets, isorange,
                               profile=DEFAULT_PROFILE,
                               unit_factor=UNIT_FACTOR_ISOCHRONE,
                               number_of_angles=MATRIX_NUM_ANGLES):
        response = self._matrix_client.matrix([origin] + targets,
                                              profile)
        json_response = json.loads(response)

        costs = [None] * number_of_angles

        for idx, cost in enumerate(json_response[ENTRY_DURATIONS][0][1:]):
            if cost:
                costs[idx] = cost * unit_factor
            else:
                costs[idx] = isorange

        return costs

    def calculate_isochrone(self, origin, time_ranges,
                            profile=DEFAULT_PROFILE):
        validate_profile(profile)

        max_speed = MAX_SPEEDS[profile]

        isochrones = []
        for time_range in time_ranges:
            upper_rmax = max_speed * time_range  # an upper bound for the radius

            coordinates = self.calculate_isoline(origin=origin,
                                                 isorange=time_range,
                                                 upper_rmax=upper_rmax,
                                                 cost_method=self._calculate_matrix_cost,
                                                 profile=profile,
                                                 unit_factor=UNIT_FACTOR_ISOCHRONE,
                                                 number_of_angles=MATRIX_NUM_ANGLES,
                                                 max_iterations=MATRIX_MAX_ITERS,
                                                 tolerance=MATRIX_TOLERANCE)
            isochrones.append(MapboxIsochronesResponse(coordinates,
                                                       time_range))
        return isochrones

    def calculate_isodistance(self, origin, distance_range,
                              profile=DEFAULT_PROFILE):
        validate_profile(profile)

        max_speed = MAX_SPEEDS[profile]
        time_range = distance_range / max_speed

        return self.calculate_isochrone(origin=origin,
                                        time_ranges=[time_range],
                                        profile=profile)[0].coordinates

    def calculate_isoline(self, origin, isorange, upper_rmax,
                          cost_method=_calculate_matrix_cost,
                          profile=DEFAULT_PROFILE,
                          unit_factor=DEFAULT_UNIT_FACTOR,
                          number_of_angles=DEFAULT_NUM_ANGLES,
                          max_iterations=DEFAULT_MAX_ITERS,
                          tolerance=DEFAULT_TOLERANCE):
        # Formally, a solution is an array of {angle, radius, lat, lon, cost}
        # with cardinality number_of_angles
        # we're looking for a solution in which
        # abs(cost - isorange) / isorange <= TOLERANCE

        # Initial setup
        angles = get_angles(number_of_angles)
        rmax = [upper_rmax] * number_of_angles
        rmin = [0.0] * number_of_angles
        location_estimates = [calculate_dest_location(origin, a,
                                                      upper_rmax / 2.0)
                              for a in angles]

        # Iterate to refine the first solution
        for i in xrange(0, max_iterations):
            # Calculate the "actual" cost for each location estimate.
            # NOTE: sometimes it cannot calculate the cost and returns None.
            #   Just assume isorange and stop the calculations there

            costs = cost_method(origin=origin, targets=location_estimates,
                                isorange=isorange, profile=profile,
                                unit_factor=unit_factor,
                                number_of_angles=number_of_angles)

            errors = [(cost - isorange) / float(isorange) for cost in costs]
            max_abs_error = max([abs(e) for e in errors])
            if max_abs_error <= tolerance:
                # good enough, stop there
                break

            # let's refine the solution, binary search
            for j in xrange(0, number_of_angles):

                if abs(errors[j]) > tolerance:
                    if errors[j] > 0:
                        rmax[j] = (rmax[j] + rmin[j]) / 2.0
                    else:
                        rmin[j] = (rmax[j] + rmin[j]) / 2.0

                    location_estimates[j] = calculate_dest_location(origin,
                                                                    angles[j],
                                                                    (rmax[j] + rmin[j]) / 2.0)

        # delete points that got None
        location_estimates_filtered = []
        for i, c in enumerate(costs):
            if c != isorange:
                location_estimates_filtered.append(location_estimates[i])

        return location_estimates_filtered


class MapboxIsochronesResponse:

    def __init__(self, coordinates, duration):
        self._coordinates = coordinates
        self._duration = duration

    @property
    def coordinates(self):
        return self._coordinates

    @property
    def duration(self):
        return self._duration
