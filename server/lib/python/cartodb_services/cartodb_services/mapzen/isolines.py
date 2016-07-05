from math import cos, sin, tan, sqrt, pi, radians, degrees, asin, atan2

class MapzenIsolines:

    NUMBER_OF_ANGLES = 12
    MAX_ITERS = 5
    TOLERANCE = 0.1

    EARTH_RADIUS_METERS = 6371000

    def __init__(self, matrix_client):
        self._matrix_client = matrix_client

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
    def calculate_isochrone(self, origin, transport_mode, isorange):
        if transport_mode != 'walk':
            # TODO move this restriction to the appropriate place
            raise NotImplementedError('walk is the only supported mode for the moment')

        # Formally, a solution is an array of {angle, radius, lat, lon, cost} with cardinality NUMBER_OF_ANGLES
        # we're looking for a solution in which abs(cost - isorange) / isorange <= TOLERANCE

        # Initial setup
        angles = self._get_angles(self.NUMBER_OF_ANGLES) # array of angles
        upper_rmax = 3.3333333 * isorange # an upper bound for the radius, assuming 12km/h walking speed
        rmax = [upper_rmax] * self.NUMBER_OF_ANGLES
        rmin = [0.0] * self.NUMBER_OF_ANGLES
        location_estimates = [self._calculate_dest_location(origin, a, upper_rmax / 2.0) for a in angles]

        # calculate the "actual" cost for each location estimate as first iteration
        resp = self._matrix_client.one_to_many([origin] + location_estimates,  'pedestrian')
        costs = [c['time'] for c in resp['one_to_many'][0][1:]]
        #import pdb; pdb.set_trace()

        # iterate to refine the first solution, if needed
        for i in xrange(0, self.MAX_ITERS):
            errors = [(cost - isorange) / float(isorange) for cost in costs]
            max_abs_error = [abs(e) for e in errors]
            if max_abs_error <= self.TOLERANCE:
                # good enough, stop there
                break

            # let's refine the solution, binary search
            for j in xrange(0, self.NUMBER_OF_ANGLES):
                if errors[j] > 0:
                    rmax[j] = (rmax[j] - rmin[j]) / 2.0
                else:
                    rmin[j] = (rmax[j] - rmin[j]) / 2.0
                location_estimates[j] = self._calculate_dest_location(origin, angles[j], (rmax[j]-rmin[j])/2.0)

            # and check "actual" costs again
            resp = self._matrix_client.one_to_many([origin] + location_estimates,  'pedestrian')
            costs = [c['time'] for c in resp['one_to_many'][0][1:]]

        return location_estimates



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
