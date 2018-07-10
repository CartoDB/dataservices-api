from multiprocessing import Pool
from exceptions import MalformedResult
from cartodb_services import StreetPointBulkGeocoder
from cartodb_services.geocoder import compose_address
from cartodb_services.google import GoogleMapsGeocoder


def async_geocoder(geocoder, address, components):
    results = geocoder.geocode(address=address, components=components)
    return results if results else []


class GoogleMapsBulkGeocoder(GoogleMapsGeocoder, StreetPointBulkGeocoder):
    """A Google Maps Geocoder wrapper for python"""
    MAX_BATCH_SIZE = 1000
    MIN_BATCHED_SEARCH = 2  # Batched is a parallelization
    PARALLEL_PROCESSES = 13

    def __init__(self, client_id, client_secret, logger):
        GoogleMapsGeocoder.__init__(self, client_id, client_secret, logger)

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
            (cartodb_id, street, city, state, country) = search
            address = compose_address(street, city, state, country)
            components = self._build_optional_parameters(city, state, country)
            result = self.geocoder.geocode(address=address, components=components)
            lng_lat = self._extract_lng_lat_from_result(result[0]) if result else []
            self._logger.debug('--> lng_lat: {}'.format(lng_lat))
            results.append((cartodb_id, lng_lat, []))
        return results

    def _batch_geocode(self, searches):
        bulk_results = {}
        pool = Pool(processes=self.PARALLEL_PROCESSES)
        for search in searches:
            (cartodb_id, street, city, state, country) = search
            components = self._build_optional_parameters(city, state, country)
            # Geocoding works better if components are also inside the address
            address = compose_address(street, city, state, country)
            if address:
                self._logger.debug('async geocoding --> {} {}'.format(address.encode('utf-8'), components))
                result = pool.apply_async(async_geocoder,
                                          (self.geocoder, address, components))
            else:
                result = []
            bulk_results[cartodb_id] = result
        pool.close()
        pool.join()

        try:
            results = []
            for cartodb_id, bulk_result in bulk_results.items():
                try:
                    result = bulk_result.get()
                except Exception as e:
                    self._logger.error('Error at Google async_geocoder', e)
                    result = []

                lng_lat = self._extract_lng_lat_from_result(result[0]) if result else []
                results.append((cartodb_id, lng_lat, []))
            return results
        except KeyError as e:
            self._logger.error('KeyError error', exception=e)
            raise MalformedResult()
        except Exception as e:
            self._logger.error('General error', exception=e)
            raise e

