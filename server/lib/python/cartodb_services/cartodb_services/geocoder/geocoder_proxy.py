from cartodb_services.metrics import Traceable
from cartodb_services.geocoder.cacheable_geocoder import is_geocoder_cacheable, CacheableGeocoder
from types import MAPBOX, GOOGLE, HERE


class GeocoderProxy(Traceable):
    def __init__(self, geocoderStrategy, logger):
        self._logger = logger
        geocoder_name = geocoderStrategy.findGeocoder()
        cacheable = is_geocoder_cacheable(geocoder_name)

        self._cacheable_geocoder = CacheableGeocoder(my_geocoder, cacheable, cacheable)

    def geocode(self, searchtext, city=None, state_province=None,
                country=None):
        return self._cacheable_geocoder.geocode(searchtext, city, state_province, country)


class GeocoderStrategy():
    def __init__(self, user_geocoders):
        self._user_geocoders = user_geocoders

    def findGeocoder(self):
        raise NotImplementedError


class FirstAvailableGeocoder(GeocoderStrategy):
    available_geocoders = [MAPBOX, GOOGLE, HERE]

    def findGeocoder(self):
        user_geocoders = [gc for gc in self._user_geocoders if gc in self.available_geocoders]
        return user_geocoders[0] if user_geocoders else None


class CheapestGeocoder(GeocoderStrategy):
    ordered_by_price = [MAPBOX, GOOGLE, HERE]

    def findGeocoder(self):
        user_geocoders_ordered = [gc for gc in self.ordered_by_price if gc in self._user_geocoders]
        return user_geocoders_ordered[0] if user_geocoders_ordered else None
