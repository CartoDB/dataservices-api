from math import cos, sin, pi, radians, degrees, asin, atan2
from cartodb_services.tools import Coordinate

EARTH_RADIUS_METERS = 6367444


def get_angles(number_of_angles):  # Angle in radians
    step = (2.0 * pi) / number_of_angles
    return [(x * step) for x in xrange(0, number_of_angles)]

def calculate_dest_location(origin, angle, radius):  # Angle in radians
    origin_lat_radians = radians(origin.latitude)
    origin_long_radians = radians(origin.longitude)
    dest_lat_radians = asin(sin(origin_lat_radians) * cos(radius / EARTH_RADIUS_METERS) + cos(origin_lat_radians) * sin(radius / EARTH_RADIUS_METERS) * cos(angle))
    dest_lng_radians = origin_long_radians + atan2(sin(angle) * sin(radius / EARTH_RADIUS_METERS) * cos(origin_lat_radians), cos(radius / EARTH_RADIUS_METERS) - sin(origin_lat_radians) * sin(dest_lat_radians))

    return Coordinate(degrees(dest_lng_radians), degrees(dest_lat_radians))
