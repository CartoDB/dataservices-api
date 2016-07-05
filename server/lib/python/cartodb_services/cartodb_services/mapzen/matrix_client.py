import requests
import json

class MatrixClient:

    ONE_TO_MANY_URL = 'https://matrix.mapzen.com/one_to_many'

    def __init__(self, matrix_key):
        self._matrix_key = matrix_key

    """Get distances and times to a set of locations.
    See https://mapzen.com/documentation/matrix/api-reference/

    Args:
        locations Array of {lat: y, lon: x}
        costing Costing model to use

    Returns:
        A dict with one_to_many, units and locations
    """    
    def one_to_many(self, locations, costing):
        request_params = {
            'json': json.dumps({'locations': locations}),
            'costing': costing,
            'api_key': self._matrix_key
        }
        response = requests.get(self.ONE_TO_MANY_URL, params=request_params)

        return response.json()
