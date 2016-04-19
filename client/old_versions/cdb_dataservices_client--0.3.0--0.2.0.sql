DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_route_point_to_point (geometry(Point, 4326), geometry(Point, 4326), text, text[], text);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_route_point_to_point (text, text, geometry(Point, 4326), geometry(Point, 4326), text, text[], text);
DROP TYPE IF EXISTS cdb_dataservices_client.simple_route;