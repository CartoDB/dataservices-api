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

        bearings = self._get_bearings(self.NUMBER_OF_ANGLES)
        location_estimates = [self._get_dest_location_estimate(origin, b, isorange) for b in bearings]

        # calculate the "actual" cost for each location estimate as first iteration
        resp = self._matrix_client.one_to_many([origin] + location_estimates,  'pedestrian')
        costs = resp['one_to_many'][0][1:]
        #import pdb; pdb.set_trace()


    # NOTE: all angles in calculations are in radians
    def _get_bearings(self, number_of_angles):
        step = (2.0 * pi) / number_of_angles
        return [(x * step) for x in xrange(0, number_of_angles)]

    # TODO: this just works for walk isochrone
    # TODO: split this into two
    def _get_dest_location_estimate(self, origin, bearing, trange):
        # my rule of thumb: normal walk speed is about 1km in 10 minutes = 6 km/h
        # use 12 km/h as an upper bound
        speed = 3.333333 # in m/s
        distance = speed * trange

        return self._calculate_dest_location(origin, bearing, distance)

    def _calculate_dest_location(self, origin, angle, radius):
        origin_lat_radians = radians(origin['lat'])
        origin_long_radians = radians(origin['lon'])
        dest_lat_radians = asin(sin(origin_lat_radians) * cos(radius / self.EARTH_RADIUS_METERS) + cos(origin_lat_radians) * sin(radius / self.EARTH_RADIUS_METERS) * cos(angle))
        dest_lng_radians = origin_long_radians + atan2(sin(angle) * sin(radius / self.EARTH_RADIUS_METERS) * cos(origin_lat_radians), cos(radius / self.EARTH_RADIUS_METERS) - sin(origin_lat_radians) * sin(dest_lat_radians))

        return {
            'lon': degrees(dest_lng_radians),
            'lat': degrees(dest_lat_radians)
        }
