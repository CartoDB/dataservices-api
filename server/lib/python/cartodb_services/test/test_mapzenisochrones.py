import mock
import unittest
import requests_mock
from mock import Mock

from cartodb_services.mapzen import MapzenIsochrones
from cartodb_services.mapzen.exceptions import ServiceException

requests_mock.Mocker.TEST_PREFIX = 'test_'

@requests_mock.Mocker()
class MapzenIsochronesTestCase(unittest.TestCase):
    MAPZEN_ISOCHRONES_URL = 'https://matrix.mapzen.com/isochrone'

    ERROR_RESPONSE = """{
      "error_code": 171,
      "error": "No suitable edges near location",
      "status_code": 400,
      "status": "Bad Request"
    }"""

    GOOD_RESPONSE = """{"features":[{"properties":{"opacity":0.33,"contour":15,"color":"tbd"},"type":"Feature","geometry":{"coordinates":[[-3.702579,40.430893],[-3.702193,40.430122],[-3.702579,40.430893]],"type":"LineString"}},{"properties":{"opacity":0.33,"contour":5,"color":"tbd"},"type":"Feature","geometry":{"coordinates":[[-3.703050,40.424995],[-3.702546,40.424694],[-3.703050,40.424995]],"type":"LineString"}}],"type":"FeatureCollection"}"""

    def setUp(self):
        self.logger = Mock()
        self.mapzen_isochrones = MapzenIsochrones('matrix-xxxxx', self.logger)

    def test_calculate_isochrone(self, req_mock):
        req_mock.register_uri('GET', self.MAPZEN_ISOCHRONES_URL,
                               text=self.GOOD_RESPONSE)

        response = self.mapzen_isochrones.isochrone([-41.484375, 28.993727],
                                                    'walk', [300, 900])

        self.assertEqual(len(response), 2)
        self.assertEqual(response[0].coordinates, [[-3.702579,40.430893],[-3.702193,40.430122],[-3.702579,40.430893]])
        self.assertEqual(response[0].duration, 15)
        self.assertEqual(response[1].coordinates, [[-3.703050,40.424995],[-3.702546,40.424694],[-3.703050,40.424995]])
        self.assertEqual(response[1].duration, 5)

    def test_calculate_isochrone_error_400_returns_empty(self, req_mock):
        req_mock.register_uri('GET', self.MAPZEN_ISOCHRONES_URL,
                               text=self.ERROR_RESPONSE, status_code=400)

        response = self.mapzen_isochrones.isochrone([-41.484375, 28.993727],
                                                    'walk', [300, 900])
        self.assertEqual(response, [])

    def test_calculate_isochrone_error_500_returns_exception(self, req_mock):
        req_mock.register_uri('GET', self.MAPZEN_ISOCHRONES_URL,
                              text=self.ERROR_RESPONSE, status_code=500)
        with self.assertRaises(ServiceException):
            self.mapzen_isochrones.isochrone([-41.484375, 28.993727],
                                             'walk', [300, 900])
