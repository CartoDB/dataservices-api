import unittest
from cartodb_services.mapbox import MapboxGeocoder
from cartodb_services.mapbox import ServiceException

INVALID_TOKEN = 'invalid_token'
VALID_ADDRESS = 'Calle Siempreviva 3, Valladolid'
WELL_KNOWN_LONGITUDE = -4.730947
WELL_KNOWN_LATITUDE = 41.668654


class MapboxGeocoderTestCase(unittest.TestCase):
    def setUp(self):
        self.geocoder = MapboxGeocoder()

    def test_invalid_token(self):
        invalid_geocoder = MapboxGeocoder(token=INVALID_TOKEN)
        with self.assertRaises(ServiceException):
            invalid_geocoder.geocode(VALID_ADDRESS)

    def test_valid_request(self):
        place = self.geocoder.geocode(VALID_ADDRESS)

        self.assertEqual(place[0], WELL_KNOWN_LONGITUDE)
        self.assertEqual(place[1], WELL_KNOWN_LATITUDE)
