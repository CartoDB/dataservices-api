from cartodb_services.here.geocoder import HereMapsGeocoder, HereMapsGeocoderV7
from cartodb_services.here.bulk_geocoder import HereMapsBulkGeocoder, HereMapsBulkGeocoderV7
from cartodb_services.here.routing import HereMapsRoutingIsoline, HereMapsRoutingIsolineV8

GEOCODING_DEFAULT_MAXRESULTS = 1

def get_geocoder(logger, app_id=None, app_code=None, service_params=None, maxresults=GEOCODING_DEFAULT_MAXRESULTS, use_apikey=False, apikey=None):
    if use_apikey is True:
        return HereMapsGeocoderV7(apikey=apikey, logger=logger,
                                    service_params=service_params,
                                    limit=maxresults)
    else:
        return HereMapsGeocoder(app_id=app_id, app_code=app_code,
                                    logger=logger,
                                    service_params=service_params,
                                    maxresults=maxresults)


def get_bulk_geocoder(logger, app_id=None, app_code=None, service_params=None, use_apikey=False, apikey=None):
    if use_apikey is True:
        return HereMapsBulkGeocoderV7(apikey=apikey, logger=logger,
                                    service_params=service_params)
    else:
        return HereMapsBulkGeocoder(app_id=app_id, app_code=app_code,
                                    logger=logger,
                                    service_params=service_params)

def get_routing_isoline(logger, app_id=None, app_code=None, service_params=None, use_apikey=False, apikey=None):
    if use_apikey is True:
        return HereMapsRoutingIsolineV8(apikey=apikey, logger=logger,
                                    service_params=service_params)
    else:
        return HereMapsRoutingIsoline(app_id=app_id, app_code=app_code,
                                    logger=logger,
                                    service_params=service_params)