import os


def mapbox_api_key():
    """Returns Mapbox API key. Requires setting MAPBOX_API_KEY environment variable."""
    return os.environ['MAPBOX_API_KEY']


def tomtom_api_key():
    """Returns TomTom API key. Requires setting TOMTOM_API_KEY environment variable."""
    return os.environ['TOMTOM_API_KEY']


def google_api_key():
    """Returns Google API key. Requires setting GOOGLE_API_KEY environment variable."""
    return os.environ['GOOGLE_API_KEY']
