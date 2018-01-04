import requests
import json
from cartodb_services.tools.qps import qps_retry
from exceptions import ServiceException
from cartodb_services.metrics import Traceable


class MatrixClient(Traceable):

    """
    A minimal client for Mapzen Time-Distance Matrix Service

    Example:

    client = MatrixClient('your_api_key')
    locations = [{"lat":40.744014,"lon":-73.990508},{"lat":40.739735,"lon":-73.979713},{"lat":40.752522,"lon":-73.985015},{"lat":40.750117,"lon":-73.983704},{"lat":40.750552,"lon":-73.993519}]
    costing = 'pedestrian'

    print client.one_to_many(locations, costing)
    """

    ONE_TO_MANY_URL = 'https://matrix.mapzen.com/one_to_many'
    READ_TIMEOUT = 60
    CONNECT_TIMEOUT = 10

    def __init__(self, matrix_key, logger, service_params=None):
        service_params = service_params or {}
        self._matrix_key = matrix_key
        self._logger = logger
        self._url = service_params.get('one_to_many_url', self.ONE_TO_MANY_URL)
        self._connect_timeout = service_params.get('connect_timeout', self.CONNECT_TIMEOUT)
        self._read_timeout = service_params.get('read_timeout', self.READ_TIMEOUT)


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
        response = requests.get(self._url, params=request_params,
                                timeout=(self._connect_timeout, self._read_timeout))
        self.add_response_data(response, self._logger)

        if response.status_code != requests.codes.ok:
            self._logger.error('Error trying to get matrix distance from mapzen',
                               data={"response_status": response.status_code,
                                     "response_reason": response.reason,
                                     "response_content": response.text,
                                     "reponse_url": response.url,
                                     "response_headers": response.headers,
                                     "locations": locations,
                                     "costing": costing})
            # In case 4xx error we return empty because the error comes from
            # the provided info by the user and we don't want to top the
            # isolines generation
            if response.status_code == requests.codes.bad_request:
                return {}
            elif response.status_code == 504:
                # Due to some unsolved problems in the Mapzen Matrix API we're
                # getting randomly 504, probably timeouts. To avoid raise an
                # exception in all the jobs, for now we're going to return
                # empty in that case
                return {}
            else:
                raise ServiceException("Error trying to get matrix distance from mapzen", response)

        # response could return with empty json
        try:
            return response.json()
        except:
            return {}
