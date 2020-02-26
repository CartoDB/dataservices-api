from cartodb_services.google import GoogleMapsBulkGeocoder
from cartodb_services.here import HereMapsBulkGeocoder
from cartodb_services.tomtom import TomTomBulkGeocoder
from cartodb_services.mapbox import MapboxBulkGeocoder
from cartodb_services.geocodio import GeocodioBulkGeocoder

BATCH_GEOCODER_CLASS_BY_PROVIDER = {
    'google': GoogleMapsBulkGeocoder,
    'heremaps': HereMapsBulkGeocoder,
    'tomtom': TomTomBulkGeocoder,
    'mapbox': MapboxBulkGeocoder,
    'geocodio': GeocodioBulkGeocoder,
}
