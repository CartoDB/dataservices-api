import unittest
from mock import Mock
from cartodb_services.mapbox import MapboxGeocoder
from cartodb_services.tools.exceptions import ServiceException
from credentials import mapbox_api_key

INVALID_TOKEN = 'invalid_token'
VALID_ADDRESS = 'Calle Siempreviva 3, Valladolid'
WELL_KNOWN_LONGITUDE = -4.730947
WELL_KNOWN_LATITUDE = 41.668654

PRECISION_FORMAT = '%.3f'

class MapboxGeocoderTestCase(unittest.TestCase):
    def setUp(self):
        self.geocoder = MapboxGeocoder(token=mapbox_api_key(), logger=Mock())

    def test_invalid_token(self):
        invalid_geocoder = MapboxGeocoder(token=INVALID_TOKEN, logger=Mock())
        with self.assertRaises(ServiceException):
            invalid_geocoder.geocode(VALID_ADDRESS)

    def test_valid_request(self):
        place = self.geocoder.geocode(VALID_ADDRESS)

        self.assertEqual(PRECISION_FORMAT % place[0], PRECISION_FORMAT % WELL_KNOWN_LONGITUDE)
        self.assertEqual(PRECISION_FORMAT % place[1], PRECISION_FORMAT % WELL_KNOWN_LATITUDE)

    def test_valid_request_namedplace(self):
        place = self.geocoder.geocode(searchtext='Barcelona')

        assert place

    def test_valid_request_namedplace2(self):
        place = self.geocoder.geocode(searchtext='New York', country='us')

        assert place

    def test_odd_characters(self):
        place = self.geocoder.geocode(searchtext='Barcelona; &quot;Spain&quot;')

        assert place

    def test_empty_request(self):
        place = self.geocoder.geocode(searchtext='', country=None, city=None, state_province=None)

        assert place == []

    def test_empty_search_text_request(self):
        place = self.geocoder.geocode(searchtext='     ', country='us', city=None, state_province="")

        assert place == []

    def test_unknown_place_request(self):
        place = self.geocoder.geocode(searchtext='[unknown]', country='ch', state_province=None, city=None)

        assert place == []
