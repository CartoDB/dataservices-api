from cartodb_services import StreetPointBulkGeocoder
from cartodb_services.tomtom import TomTomGeocoder


class TomTomBulkGeocoder(TomTomGeocoder, StreetPointBulkGeocoder):
    # TODO: ?
    MAX_BATCH_SIZE = 1000000  # From the docs
    # TODO: ?
    MIN_BATCHED_SEARCH = 100  # Under this, serial will be used

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
            (search_id, address, city, state, country) = search
            self._logger.debug('--> Sending serial search: {}'.format(search))
            coordinates = self.geocode(searchtext=address.encode('utf-8'),
                                       city=city.encode('utf-8'),
                                       state_province=state.encode('utf-8'),
                                       country=country.encode('utf-8'))
            self._logger.debug('--> result sent')
            results.append((search_id, coordinates, []))
        return results

