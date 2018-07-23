from multiprocessing import Pool
from exceptions import MalformedResult
from cartodb_services import StreetPointBulkGeocoder
from cartodb_services.geocoder import compose_address, geocoder_error_response
from cartodb_services.google import GoogleMapsGeocoder


def async_geocoder(geocoder, address, components):
    return geocoder.geocode(address=address, components=components)


class GoogleMapsBulkGeocoder(GoogleMapsGeocoder, StreetPointBulkGeocoder):
    """A Google Maps Geocoder wrapper for python"""
    MAX_BATCH_SIZE = 1000
    MIN_BATCHED_SEARCH = 2  # Batched is a parallelization
    PARALLEL_PROCESSES = 13

    def __init__(self, client_id, client_secret, logger):
        GoogleMapsGeocoder.__init__(self, client_id, client_secret, logger)

    def _should_use_batch(self, searches):
        return len(searches) >= self.MIN_BATCHED_SEARCH

    def _serial_geocode(self, searches):
        results = []
        for search in searches:
            (cartodb_id, street, city, state, country) = search
            try:
                lng_lat, metadata = self.geocode_meta(street, city, state, country)
                result = (cartodb_id, lng_lat, metadata)
            except Exception as e:
                self._logger.error("Error geocoding", e)
                result = geocoder_error_response("Error geocoding")
            results.append(result)
        return results

    def _batch_geocode(self, searches):
        bulk_results = {}
        pool = Pool(processes=self.PARALLEL_PROCESSES)
        for search in searches:
            (cartodb_id, street, city, state, country) = search
            address = compose_address(street, city, state, country)
            if address:
                components = self._build_optional_parameters(city, state, country)
                result = pool.apply_async(async_geocoder,
                                          (self.geocoder, address, components))
                bulk_results[cartodb_id] = result
        pool.close()
        pool.join()

        try:
            results = []
            for cartodb_id, bulk_result in bulk_results.items():
                try:
                    lng_lat, metadata = self._process_results(bulk_result.get())
                except Exception as e:
                    msg = 'Error at Google async_geocoder'
                    self._logger.error(msg, e)
                    lng_lat, metadata = geocoder_error_response(msg)

                results.append((cartodb_id, lng_lat, metadata))
            return results
        except Exception as e:
            self._logger.error('General error', exception=e)
            raise e
