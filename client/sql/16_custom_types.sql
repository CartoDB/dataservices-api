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

-- For the OBS_Meta functions
CREATE TYPE cdb_dataservices_client.obs_meta_numerator AS (numer_id text, numer_name text, numer_description text, numer_weight text, numer_license text, numer_source text, numer_type text, numer_aggregate text, numer_extra jsonb, numer_tags jsonb, valid_denom boolean, valid_geom boolean, valid_timespan boolean);

CREATE TYPE cdb_dataservices_client.obs_meta_denominator AS (denom_id text, denom_name text, denom_description text, denom_weight text, denom_license text, denom_source text, denom_type text, denom_aggregate text, denom_extra jsonb, denom_tags jsonb, valid_numer boolean, valid_geom boolean, valid_timespan boolean);

CREATE TYPE cdb_dataservices_client.obs_meta_geometry AS (geom_id text, geom_name text, geom_description text, geom_weight text, geom_aggregate text, geom_license text, geom_source text, geom_type text, geom_extra jsonb, geom_tags jsonb, valid_numer boolean, valid_denom boolean, valid_timespan boolean, score numeric, numtiles bigint, notnull_percent numeric, numgeoms numeric, percentfill numeric, estnumgeoms numeric, meanmediansize numeric);

CREATE TYPE cdb_dataservices_client.obs_meta_timespan AS (timespan_id text, timespan_name text, timespan_description text, timespan_weight text, timespan_aggregate text, timespan_license text, timespan_source text, timespan_type text, timespan_extra jsonb, timespan_tags jsonb, valid_numer boolean, valid_denom boolean, valid_geom boolean);


-- For quotas and services configuration
CREATE TYPE cdb_dataservices_client.service_type AS ENUM (
    'isolines',
    'hires_geocoder',
    'routing',
    'observatory'
);

CREATE TYPE cdb_dataservices_client.service_quota_info AS (
    service cdb_dataservices_client.service_type,
    monthly_quota NUMERIC,
    used_quota NUMERIC,
    soft_limit BOOLEAN,
    provider TEXT
);
