from google import GoogleMapsBulkGeocoder
from here import HereMapsBulkGeocoder
from tomtom import TomTomBulkGeocoder
from mapbox import MapboxBulkGeocoder

BATCH_GEOCODER_CLASS_BY_PROVIDER = {
    'google': GoogleMapsBulkGeocoder,
    'heremaps': HereMapsBulkGeocoder,
    'tomtom': TomTomBulkGeocoder,
    'mapbox': MapboxBulkGeocoder
}
