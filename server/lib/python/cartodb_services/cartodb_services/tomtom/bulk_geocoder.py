import json, requests, time
from requests.adapters import HTTPAdapter
from cartodb_services import StreetPointBulkGeocoder
from cartodb_services.geocoder import geocoder_error_response
from cartodb_services.tomtom import TomTomGeocoder
from cartodb_services.tools.exceptions import ServiceException


class TomTomBulkGeocoder(TomTomGeocoder, StreetPointBulkGeocoder):
    MAX_BATCH_SIZE = 1000000  # From the docs
    MIN_BATCHED_SEARCH = 10  # Batch API is really fast
    BASE_URL = 'https://api.tomtom.com'
    BATCH_URL = BASE_URL + '/search/2/batch.json'
    MAX_STALLED_RETRIES = 100
    BATCH_RETRY_SLEEP_S = 5
    READ_TIMEOUT = 60
    CONNECT_TIMEOUT = 10
    MAX_RETRIES = 1

    def __init__(self, apikey, logger, service_params=None):
        TomTomGeocoder.__init__(self, apikey, logger, service_params)
        self.connect_timeout = service_params.get('connect_timeout', self.CONNECT_TIMEOUT)
        self.read_timeout = service_params.get('read_timeout', self.READ_TIMEOUT)
        self.max_retries = service_params.get('max_retries', self.MAX_RETRIES)
        self.session = requests.Session()
        self.session.headers.update({'Content-Type': 'application/json'})
        self.session.mount(self.BATCH_URL,
                           HTTPAdapter(max_retries=self.max_retries))

    def _should_use_batch(self, searches):
        return len(searches) >= self.MIN_BATCHED_SEARCH

    def _serial_geocode(self, searches):
        results = []
        for search in searches:
            (search_id, address, city, state, country) = search
            address = address.encode('utf-8') if address else None
            city = city.encode('utf-8') if city else None
            state = state.encode('utf-8') if state else None
            country = country.encode('utf-8') if country else None
            result = self.geocode_meta(searchtext=address, city=city,
                                       state_province=state, country=country)
            results.append((search_id, result[0], result[1]))
        return results

    def _batch_geocode(self, searches):
        full_results = self._geocode_searches(searches)
        results = []
        for s, r in zip(searches, full_results):
            results.append((s[0], r[0], r[1]))
        return results

    def _geocode_searches(self, searches):
        try:
            location = self._send_batch(searches)
            return self._download_results(location)
        except Exception as e:
            msg = "Error running TomTom batch geocode: {}".format(e)
            self._logger.error(msg, e)
            return [geocoder_error_response(msg)] * len(searches)

    def _send_batch(self, searches):
        body = {'batchItems': [{'query': self._query(s)} for s in searches]}
        request_params = {
            'key': self._apikey
        }
        response = self.session.post(self.BATCH_URL, data=json.dumps(body),
                                     allow_redirects=False,
                                     params=request_params,
                                     timeout=(self.connect_timeout, self.read_timeout))
        if response.status_code == 303:
            return response.headers['Location']
        else:
            msg = "Error sending batch: {}; Headers: {}".format(
                response.text.encode('utf-8'), response.headers)
            self._logger.error(msg)
            raise ServiceException(msg, response)

    def _download_results(self, location):
        stalled_retries = 0
        while True:
            response = self.session.get(self.BASE_URL + location)
            if response.status_code == 200:
                return self._parse_results(response.json())
            elif response.status_code == 202:
                stalled_retries += 1
                if stalled_retries > self.MAX_STALLED_RETRIES:
                    raise Exception('Too many retries for job {}'.format(location))
                location = response.headers['Location']
                time.sleep(self.BATCH_RETRY_SLEEP_S)
            else:
                msg = "Error downloading batch: {}; Headers: {}".format(
                    response.text.encode('utf-8'), response.headers)
                self._logger.error(msg)
                raise ServiceException(msg, response)

    def _query(self, search):
        (search_id, address, city, state, country) = search
        searchtext = ', '.join(filter(None, [address, city, state]))
        return self._request_uri(searchtext=searchtext, country=country)

    def _parse_results(self, json_body):
        return [self._parse_response(item['statusCode'], item['response'])
                for item in json_body['batchItems']]

