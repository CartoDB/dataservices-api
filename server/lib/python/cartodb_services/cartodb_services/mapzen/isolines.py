from math import cos, sin, tan, sqrt, pi, radians, degrees, asin, atan2


class MapzenIsolines:

    NUMBER_OF_ANGLES = 24
    MAX_ITERS = 5
    TOLERANCE = 0.1

    EARTH_RADIUS_METERS = 6367444

    def __init__(self, matrix_client, logger):
        self._matrix_client = matrix_client
        self._logger = logger

    """Get an isochrone using mapzen API.

    The implementation tries to sick close to the SQL API:
    cdb_isochrone(source geometry, mode text, range integer[], [options text[]]) -> SETOF isoline

    But this calculates just one isoline.

    Args:
        origin dict containing {lat: y, lon: x}
        transport_mode string, for the moment just "car" or "walk"
        isorange int range of the isoline in seconds

    Returns:
        Array of {lon: x, lat: y} as a representation of the isoline
    """
    def calculate_isochrone(self, origin, transport_mode, time_range):
        if transport_mode == 'walk':
            max_speed = 3.3333333 # In m/s, assuming 12km/h walking speed
            costing_model = 'pedestrian'
        elif transport_mode == 'car':
            max_speed = 41.67 # In m/s, assuming 140km/h max speed
            costing_model = 'auto'
        else:
            raise NotImplementedError('car and walk are the only supported modes for the moment')

        upper_rmax = max_speed * time_range # an upper bound for the radius

        return self.calculate_isoline(origin, costing_model, time_range, upper_rmax, 'time')

    """Get an isodistance using mapzen API.

    Args:
        origin dict containing {lat: y, lon: x}
        transport_mode string, for the moment just "car" or "walk"
        isorange int range of the isoline in seconds

    Returns:
        Array of {lon: x, lat: y} as a representation of the isoline
    """
    def calculate_isodistance(self, origin, transport_mode, distance_range):
        if transport_mode == 'walk':
            costing_model = 'pedestrian'
        elif transport_mode == 'car':
            costing_model = 'auto'
        else:
            raise NotImplementedError('car and walk are the only supported modes for the moment')

        upper_rmax = distance_range # an upper bound for the radius, going in a straight line

        return self.calculate_isoline(origin, costing_model, distance_range, upper_rmax, 'distance', 1000.0)


    """Get an isoline using mapzen API.

    The implementation tries to sick close to the SQL API:
    cdb_isochrone(source geometry, mode text, range integer[], [options text[]]) -> SETOF isoline

    But this calculates just one isoline.

    Args:
        origin dict containing {lat: y, lon: x}
        costing_model string "auto" or "pedestrian"
        isorange int Range of the isoline in seconds
        upper_rmax float An upper bound for the binary search
        cost_variable string Variable to optimize "time" or "distance"
        unit_factor float A factor to adapt units of isorange (meters) and units of distance (km)

    Returns:
        Array of {lon: x, lat: y} as a representation of the isoline
    """
    def calculate_isoline(self, origin, costing_model, isorange, upper_rmax, cost_variable, unit_factor=1.0):

        # NOTE: not for production
        # self._logger.debug('Calculate isoline', data={"origin": origin, "costing_model": costing_model, "isorange": isorange})

        # Formally, a solution is an array of {angle, radius, lat, lon, cost} with cardinality NUMBER_OF_ANGLES
        # we're looking for a solution in which abs(cost - isorange) / isorange <= TOLERANCE

        # Initial setup
        angles = self._get_angles(self.NUMBER_OF_ANGLES) # array of angles
        rmax = [upper_rmax] * self.NUMBER_OF_ANGLES
        rmin = [0.0] * self.NUMBER_OF_ANGLES
        location_estimates = [self._calculate_dest_location(origin, a, upper_rmax / 2.0) for a in angles]

        # Iterate to refine the first solution
        for i in xrange(0, self.MAX_ITERS):
            # Calculate the "actual" cost for each location estimate.
            # NOTE: sometimes it cannot calculate the cost and returns None.
            #   Just assume isorange and stop the calculations there

            response = self._matrix_client.one_to_many([origin] + location_estimates,  costing_model)
            costs = [None] * self.NUMBER_OF_ANGLES
            if not response:
                # In case the matrix client doesn't return any data
                break

            for idx, c in enumerate(response['one_to_many'][0][1:]):
                if c[cost_variable]:
                    costs[idx] = c[cost_variable]*unit_factor
                else:
                    costs[idx] = isorange

            errors = [(cost - isorange) / float(isorange) for cost in costs]
            max_abs_error = max([abs(e) for e in errors])
            if max_abs_error <= self.TOLERANCE:
                # good enough, stop there
                break

            # let's refine the solution, binary search
            for j in xrange(0, self.NUMBER_OF_ANGLES):

                if abs(errors[j]) > self.TOLERANCE:
                    if errors[j] > 0:
                        rmax[j] = (rmax[j] + rmin[j]) / 2.0
                    else:
                        rmin[j] = (rmax[j] + rmin[j]) / 2.0

                    location_estimates[j] = self._calculate_dest_location(origin, angles[j], (rmax[j]+rmin[j])/2.0)

        # delete points that got None
        location_estimates_filtered = []
        for i, c in enumerate(costs):
            if c <> isorange:
                location_estimates_filtered.append(location_estimates[i])

        return location_estimates_filtered



    # NOTE: all angles in calculations are in radians
    def _get_angles(self, number_of_angles):
        step = (2.0 * pi) / number_of_angles
        return [(x * step) for x in xrange(0, number_of_angles)]

    def _calculate_dest_location(self, origin, angle, radius):
        origin_lat_radians = radians(origin['lat'])
        origin_long_radians = radians(origin['lon'])
        dest_lat_radians = asin(sin(origin_lat_radians) * cos(radius / self.EARTH_RADIUS_METERS) + cos(origin_lat_radians) * sin(radius / self.EARTH_RADIUS_METERS) * cos(angle))
        dest_lng_radians = origin_long_radians + atan2(sin(angle) * sin(radius / self.EARTH_RADIUS_METERS) * cos(origin_lat_radians), cos(radius / self.EARTH_RADIUS_METERS) - sin(origin_lat_radians) * sin(dest_lat_radians))

        return {
            'lon': degrees(dest_lng_radians),
            'lat': degrees(dest_lat_radians)
        }
