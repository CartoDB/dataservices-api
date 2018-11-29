TOMTOM_ROUTING_APIKEY_ROUNDROBIN = 'tomtom_routing_apikey_roundrobin'
TOMTOM_GEOCODER_APIKEY_ROUNDROBIN = 'tomtom_geocoder_apikey_roundrobin'
TOMTOM_ISOLINES_APIKEY_ROUNDROBIN = 'tomtom_isolines_apikey_roundrobin'

PROFILE_DRIVING = 'car'
PROFILE_CYCLING = 'bicycle'
PROFILE_WALKING = 'pedestrian'
DEFAULT_PROFILE = PROFILE_DRIVING

DEFAULT_DEPARTAT = 'now'

VALID_PROFILES = [PROFILE_DRIVING,
                  PROFILE_CYCLING,
                  PROFILE_WALKING]

MAX_SPEEDS = {
    PROFILE_WALKING: 3.3333333,  # In m/s, assuming 12km/h walking speed
    PROFILE_CYCLING: 16.67,  # In m/s, assuming 60km/h max speed
    PROFILE_DRIVING: 41.67  # In m/s, assuming 140km/h max speed
}

TRANSPORT_MODE_TO_TOMTOM = {
    'car': 'car',
    'walk': 'pedestrian',
    'bicycle': 'bicycle',
}

DEFAULT_ROUTE_TYPE = 'shortest'
MODE_TYPE_TO_TOMTOM = {
    'shortest': 'shortest',
    'fastest': 'fastest'
}
