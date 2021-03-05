CREATE TYPE cdb_dataservices_client.isoline AS (
    center geometry(Geometry,4326),
    data_range integer,
    the_geom geometry(Multipolygon,4326)
);

CREATE TYPE cdb_dataservices_client.geocoding AS (
    cartodb_id integer,
    the_geom geometry(Point,4326),
    metadata jsonb
);

CREATE TYPE cdb_dataservices_client.simple_route AS (
    shape geometry(LineString,4326),
    length real,
    duration integer
);

-- For quotas and services configuration
CREATE TYPE cdb_dataservices_client.service_type AS ENUM (
    'isolines',
    'hires_geocoder',
    'routing'
);

CREATE TYPE cdb_dataservices_client.service_quota_info AS (
    service cdb_dataservices_client.service_type,
    monthly_quota NUMERIC,
    used_quota NUMERIC,
    soft_limit BOOLEAN,
    provider TEXT
);

CREATE TYPE cdb_dataservices_client.service_quota_info_batch AS (
    service cdb_dataservices_client.service_type,
    monthly_quota NUMERIC,
    used_quota NUMERIC,
    soft_limit BOOLEAN,
    provider TEXT,
    max_batch_size NUMERIC
);
