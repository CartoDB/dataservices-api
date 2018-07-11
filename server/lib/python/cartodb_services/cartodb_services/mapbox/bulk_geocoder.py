import json, requests, time
from requests.adapters import HTTPAdapter
from cartodb_services import StreetPointBulkGeocoder
from cartodb_services.mapbox import MapboxGeocoder
from cartodb_services.tools.exceptions import ServiceException
from iso3166 import countries
from cartodb_services.tools.country import country_to_iso3


class MapboxBulkGeocoder(MapboxGeocoder, StreetPointBulkGeocoder):
    MAX_BATCH_SIZE = 50  # From the docs
    MIN_BATCHED_SEARCH = 0
    READ_TIMEOUT = 60
    CONNECT_TIMEOUT = 10
    MAX_RETRIES = 1

    def __init__(self, token, logger, service_params=None):
        MapboxGeocoder.__init__(self, token, logger, service_params)
        self.connect_timeout = service_params.get('connect_timeout', self.CONNECT_TIMEOUT)
        self.read_timeout = service_params.get('read_timeout', self.READ_TIMEOUT)
        self.max_retries = service_params.get('max_retries', self.MAX_RETRIES)
        self.session = requests.Session()

    def _should_use_batch(self, searches):
        return len(searches) >= self.MIN_BATCHED_SEARCH

    def _serial_geocode(self, searches):
        results = []
        for search in searches:
            elements = self._encoded_elements(search)
            self._logger.debug('--> Sending serial search: {}'.format(search))
            result = self.geocode_meta(*elements)

            results.append((search[0], result[0], result[1]))
        return results

    def _encoded_elements(self, search):
        (search_id, address, city, state, country) = search
        address = address.encode('utf-8') if address else None
        city = city.encode('utf-8') if city else None
        state = state.encode('utf-8') if state else None
        country = self._country_code(country) if country else None
        return address, city, state, country

    def _batch_geocode(self, searches):
        if len(searches) == 1:
            return self._serial_geocode(searches)
        else:
            frees = []
            for search in searches:
                elements = self._encoded_elements(search)
                free = ', '.join([elem for elem in elements if elem])
                frees.append(free)

            self._logger.debug('--> sending free search: {}'.format(frees))
            full_results = self.geocode_free_text_meta(frees)
            results = []
            self._logger.debug('--> searches: {}; xy: {}'.format(searches, full_results))
            for s, r in zip(searches, full_results):
                results.append((s[0], r[0], r[1]))
            self._logger.debug('--> results: {}'.format(results))
            return results

    def _country_code(self, country):
        country_iso3166 = None
        country_iso3 = country_to_iso3(country)
        if country_iso3:
            country_iso3166 = countries.get(country_iso3).alpha2.lower()

        return country_iso3166

