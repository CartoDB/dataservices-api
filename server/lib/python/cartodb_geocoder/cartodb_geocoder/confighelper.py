from cartodbgeocoderexceptions import BadAuthDictionary
from cartodbgeocoderexceptions import UnknownProvider

class GeocoderAuth:
    """ Class to generate the correct auth for a given goeocder """

    GME_PROVIDER = 'google'
    HIRES_PROVIDER = 'nokia'

    GME_TRANSLATOR = {
        'identifier': 'gme_client_id',
        'secret': 'gme_client_secret'
    }

    HIRES_TRANSLATOR = {
        'identifier': 'hires_app_id',
        'secret': 'hires_app_code'
    }

    def __init__(self, auth_dict):
        try:
            self.provider = auth_dict['geocoder_service']['street_geocoder_provider']

            if self.provider == self.GME_PROVIDER: translator = self.GME_TRANSLATOR
            elif self.provider == self.HIRES_PROVIDER: translator = self.HIRES_TRANSLATOR
            else: raise UnknownProvider(self.provider)

            self.identifier = auth_dict['geocoder_service'][translator['identifier']]
            self.secret = auth_dict['geocoder_service'][translator['secret']]
        except KeyError:
            raise BadAuthDictionary()

    def get_auth_dict(self):
        auth_dict = {
            'identifier': self.identifier,
            'secret': self.secret,
            'provider': self.provider
        }

        return auth_dict
