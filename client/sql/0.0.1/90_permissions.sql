-- Make sure by default there are no permissions for publicuser
-- NOTE: this happens at extension creation time, as part of an implicit transaction.
REVOKE ALL PRIVILEGES ON SCHEMA cdb_geocoder_client FROM PUBLIC, publicuser CASCADE;

-- Grant permissions on the schema to publicuser (but just the schema)
GRANT USAGE ON SCHEMA cdb_geocoder_client TO publicuser;

-- Revoke execute permissions on all functions in the schema by default
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA cdb_geocoder_client FROM PUBLIC, publicuser;

--------------------------------------------------------------------------------

-- Explicitly grant permissions to public functions
-- NOTE: All public functions must be listed below, grating permissions to publicuser
GRANT EXECUTE ON FUNCTION cdb_geocoder_client.geocode_admin0_polygons(country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_geocoder_client.geocode_admin1_polygon(admin1_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_geocoder_client.geocode_admin1_polygon(admin1_name text, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_geocoder_client.geocode_namedplace_point(city_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_geocoder_client.geocode_namedplace_point(city_name text, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_geocoder_client.geocode_namedplace_point(city_name text, admin1_name text, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_geocoder_client.geocode_postalcode_polygon(postal_code text, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_geocoder_client.geocode_postalcode_polygon(postal_code integer, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_geocoder_client.geocode_ip(ip_address text) TO publicuser;
