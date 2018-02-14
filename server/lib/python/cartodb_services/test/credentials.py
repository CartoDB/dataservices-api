import os

def mapbox_api_key():
    """Returns Mapbox API key. Requires setting MAPBOX_API_KEY environment variable."""
    return os.environ['MAPBOX_API_KEY']

