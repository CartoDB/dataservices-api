import os


def mapbox_api_key():
    """Returns Mapbox API key. Requires setting MAPBOX_API_KEY environment variable."""
    return os.environ['MAPBOX_API_KEY']


def tomtom_api_key():
    """Returns TomTom API key. Requires setting TOMTOM_API_KEY environment variable."""
    return os.environ['TOMTOM_API_KEY']


def geocodio_api_key():
    """Returns Geocodio API key. Requires setting GEOCODIO_API_KEY environment variable."""
    return os.environ['GEOCODIO_API_KEY']
