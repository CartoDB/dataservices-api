CREATE TYPE cdb_dataservices_client.isoline AS (
    center geometry(Geometry,4326),
    data_range integer,
    the_geom geometry(Multipolygon,4326)
);

CREATE TYPE cdb_dataservices_client.simple_route AS (
    shape geometry(LineString,4326),
    length real,
    duration integer
);