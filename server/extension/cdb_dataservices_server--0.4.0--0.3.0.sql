DROP TYPE IF EXISTS isoline;

DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_isochrone(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT NULL);
DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_isodistance(username TEXT, orgname TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT NULL);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_here_routing_isolines(username TEXT, orgname TEXT, type TEXT, source geometry(Geometry, 4326), mode TEXT, range integer[], options text[] DEFAULT NULL);
DROP FUNCTION IF EXISTS cdb_dataservices_server._get_routing_config(username text, orgname text)