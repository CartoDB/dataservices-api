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
    PARALLEL_PROCESSES = 13

    def __init__(self, client_id, client_secret, logger):
        GoogleMapsGeocoder.__init__(self, client_id, client_secret, logger)

    def _bulk_geocode(self, searches):
        bulk_results = {}
        pool = Pool(processes=self.PARALLEL_PROCESSES)
        for search in searches:
            (search_id, street, city, state, country) = search
            opt_params = self._build_optional_parameters(city, state, country)
            # Geocoding works better if components are also inside the address
            address = compose_address(street, city, state, country)
            if address:
                self._logger.debug('async geocoding --> {} {}'.format(address.encode('utf-8'), opt_params))
                result = pool.apply_async(async_geocoder,
                                          (self.geocoder, address, opt_params))
            else:
                result = []
            bulk_results[search_id] = result
        pool.close()
        pool.join()

        try:
            results = []
            for search_id, bulk_result in bulk_results.items():
                try:
                    result = bulk_result.get()
                except Exception as e:
                    self._logger.error('Error at Google async_geocoder', e)
                    result = []

                lng_lat = self._extract_lng_lat_from_result(result[0]) if result else []
                results.append((search_id, lng_lat, []))
            return results
        except KeyError as e:
            self._logger.error('KeyError error', exception=e)
            raise MalformedResult()
        except Exception as e:
            self._logger.error('General error', exception=e)
            raise e

