# NOTE: This init function must be called from plpythonu entry points to
# initialize cartodb_services module properly. E.g:
#
# CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_isochrone(...)
# RETURNS SETOF cdb_dataservices_server.isoline AS $$
#
#     import cartodb_services
#     cartodb_services.init(GD)
#
#     # rest of the code here
#
# $$ LANGUAGE plpythonu;

def init(GD):
    import plpy
    plpy.GD = GD
