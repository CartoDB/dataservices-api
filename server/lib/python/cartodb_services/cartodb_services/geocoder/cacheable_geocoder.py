from types import MAPBOX

CACHEABLE_GEOCODERS = [MAPBOX]


def is_geocoder_cacheable(geocoder_name):
    return geocoder_name in CACHEABLE_GEOCODERS


class CacheableGeocoder:
    def __init__(self, geocoder, use_cache=True, save_cache=True):
        self._geocoder = geocoder
        self._use_cache = use_cache
        self._save_cache = save_cache

    def geocode(self, searchtext, city=None, state_province=None,
                country=None):
        response = None
        if self._use_cache:
            response = self._find_in_cache(searchtext, city, state_province,
                                           country)

        if not response:
            response = self._lookup_geocoder(searchtext, city, state_province,
                                             country)

        return self._geocoder.format_response(response)

    def _find_in_cache(self, searchtext, city=None, state_province=None,
                       country=None):
        normalized_address = self._normalize_address(searchtext, city,
                                                     state_province, country)

    def _save_to_cache(self, response, searchtext, city=None,
                       state_province=None, country=None):
        normalized_address = self._normalize_address(searchtext, city,
                                                     state_province, country)

    def _lookup_geocoder(self, searchtext, city=None, state_province=None,
                         country=None):
        response = self._geocoder.geocode(searchtext, city, state_province,
                                          country)

        if self._save_cache:
            self._save_to_cache(response, searchtext, city, state_province,
                                country)

        return response

    def _normalize_address(self, searchtext, city=None, state_province=None,
                           country=None):
        if searchtext and searchtext.strip():
            address = [searchtext]
            if city:
                address.append(city)
            if state_province:
                address.append(state_province)
            if country:
                address.append(country)

            address = ', '.join(address)

            return ' '.join(address.replace(',', ' ').split()).replace(' ', '_')

        return None
