import requests
import json
from qps import qps_retry


class MatrixClient:

    """
    A minimal client for Mapzen Time-Distance Matrix Service

    Example:

    client = MatrixClient('your_api_key')
    locations = [{"lat":40.744014,"lon":-73.990508},{"lat":40.739735,"lon":-73.979713},{"lat":40.752522,"lon":-73.985015},{"lat":40.750117,"lon":-73.983704},{"lat":40.750552,"lon":-73.993519}]
    costing = 'pedestrian'

    print client.one_to_many(locations, costing)
    """

    ONE_TO_MANY_URL = 'https://matrix.mapzen.com/one_to_many'

    def __init__(self, matrix_key, logger):
        self._matrix_key = matrix_key
        self._logger = logger

    """Get distances and times to a set of locations.
    See https://mapzen.com/documentation/matrix/api-reference/

    Args:
        locations Array of {lat: y, lon: x}
        costing Costing model to use

    Returns:
        A dict with one_to_many, units and locations
    """
    @qps_retry
    def one_to_many(self, locations, costing):
        request_params = {
            'json': json.dumps({'locations': locations}),
            'costing': costing,
            'api_key': self._matrix_key
        }
        response = requests.get(self.ONE_TO_MANY_URL, params=request_params)

        if response.status_code == requests.codes.ok:
            return response.json()
        elif response.status_code == requests.codes.bad_request:
            return None
        else:
            self._logger.error('Error trying to get matrix distance from mapzen',
                               data={"response_status": response.status_code,
                                     "response_reason": response.reason,
                                     "response_content": response.text,
                                     "reponse_url": response.url,
                                     "response_headers": response.headers,
                                     "locations": locations,
                                     "costing": costing})
            raise Exception('Error trying to get matrix distance from mapzen')
