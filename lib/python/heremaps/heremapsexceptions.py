import json

class BadGeocodingParams(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr('Bad geocoding params: ' + json.dumps(value))

class NoGeocodingParams(Exception):
    def __str__(self):
        return repr('No params for geocoding specified')
