DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_isochrone (geometry(Geometry, 4326), text, integer[], text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_isochrone (text, text, geometry(Geometry, 4326), text, integer[], text[]);

DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_isodistance (geometry(Geometry, 4326), text, integer[], text[]);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_isodistance (text, text, geometry(Geometry, 4326), text, integer[], text[]);

DROP TYPE IF EXISTS cdb_dataservices_client.isoline;