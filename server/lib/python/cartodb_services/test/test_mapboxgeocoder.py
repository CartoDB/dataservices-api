import unittest
from mock import Mock
from cartodb_services.mapbox import MapboxGeocoder
from cartodb_services.tools.exceptions import ServiceException

VALID_TOKEN = 'pk.eyJ1IjoiYWNhcmxvbiIsImEiOiJjamJuZjQ1Zjc0Ymt4Mnh0YmFrMmhtYnY4In0.gt9cw0VeKc3rM2mV5pcEmg'
INVALID_TOKEN = 'invalid_token'
VALID_ADDRESS = 'Calle Siempreviva 3, Valladolid'
WELL_KNOWN_LONGITUDE = -4.730947
WELL_KNOWN_LATITUDE = 41.668654


class MapboxGeocoderTestCase(unittest.TestCase):
    def setUp(self):
        self.geocoder = MapboxGeocoder(token=VALID_TOKEN, logger=Mock())

    def test_invalid_token(self):
        invalid_geocoder = MapboxGeocoder(token=INVALID_TOKEN, logger=Mock())
        with self.assertRaises(ServiceException):
            invalid_geocoder.geocode(VALID_ADDRESS)

    def test_valid_request(self):
        place = self.geocoder.geocode(VALID_ADDRESS)

        self.assertEqual(place[0], WELL_KNOWN_LONGITUDE)
        self.assertEqual(place[1], WELL_KNOWN_LATITUDE)

    def test_valid_request_namedplace(self):
        place = self.geocoder.geocode(searchtext='Barcelona')

        assert place

    def test_valid_request_namedplace2(self):
        place = self.geocoder.geocode(searchtext='New York', country='us')

        assert place
