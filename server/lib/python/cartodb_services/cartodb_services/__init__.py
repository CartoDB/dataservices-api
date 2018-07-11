# NOTE: This init function must be called from plpythonu entry points to
# initialize cartodb_services module properly. E.g:
#
# CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_isochrone(...)
# RETURNS SETOF cdb_dataservices_server.isoline AS $$
#
#     import cartodb_services
#     cartodb_services.init(plpy, GD)
#
#     # rest of the code here
#     cartodb_services.GD[key] = val
#     cartodb_services.plpy.execute('SELECT * FROM ...')
#
# $$ LANGUAGE plpythonu;

plpy = None
GD = None

def init(_plpy, _GD):
    global plpy
    global GD

    if plpy is None:
        plpy = _plpy

    if GD is None:
        GD = _GD

def _reset():
    # NOTE: just for testing
    global plpy
    global GD

    plpy = None
    GD = None

from geocoder import run_street_point_geocoder, StreetPointBulkGeocoder

PRECISION_PRECISE = 'precise'
PRECISION_INTERPOLATED = 'interpolated'
