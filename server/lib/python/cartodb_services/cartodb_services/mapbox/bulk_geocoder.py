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

    def _bulk_geocode(self, searches):
        if len(searches) > self.MAX_BATCH_SIZE:
            raise Exception("Batch size can't be larger than {}".format(self.MAX_BATCH_SIZE))
        if self._should_use_batch(searches):
            self._logger.debug('--> Batch geocode')
            return self._batch_geocode(searches)
        else:
            self._logger.debug('--> Serial geocode')
            return self._serial_geocode(searches)

    def _should_use_batch(self, searches):
        return len(searches) >= self.MIN_BATCHED_SEARCH

    def _serial_geocode(self, searches):
        results = []
        for search in searches:
            elements = self._encoded_elements(search)
            self._logger.debug('--> Sending serial search: {}'.format(search))
            coordinates = self._geocode_search(*elements)
            results.append((search[0], coordinates, []))
        return results

    def _geocode_search(self, address, city, state, country):
        coordinates = self.geocode(searchtext=address, city=city,
                                   state_province=state, country=country)
        self._logger.debug('--> result sent')
        return coordinates

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
            xy_results = self.geocode_free_text(frees)
            results = []
            self._logger.debug('--> searches: {}; xy: {}'.format(searches, xy_results))
            for s, r in zip(searches, xy_results):
                results.append((s[0], r, []))
            self._logger.debug('--> results: {}'.format(results))
            return results

    def _country_code(self, country):
        country_iso3166 = None
        country_iso3 = country_to_iso3(country)
        if country_iso3:
            country_iso3166 = countries.get(country_iso3).alpha2.lower()

        return country_iso3166

