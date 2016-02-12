DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_isochrone(TEXT, TEXT, geometry(Geometry, 4326), TEXT, integer[], text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_isodistance(TEXT, TEXT, geometry(Geometry, 4326), TEXT, integer[], text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_here_routing_isolines(TEXT, TEXT, TEXT, geometry(Geometry, 4326), TEXT, integer[], text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_server._get_routing_config(text, text);
DROP TYPE IF EXISTS cdb_dataservices_server.isoline;