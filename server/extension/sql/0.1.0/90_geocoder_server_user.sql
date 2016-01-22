DO $$
BEGIN
    IF NOT EXISTS (
        SELECT *
        FROM   pg_catalog.pg_user
        WHERE  usename = 'geocoder_api') THEN

            CREATE USER geocoder_api;
    END IF;
    GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA cdb_geocoder_server TO geocoder_api;
    GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO geocoder_api;
    GRANT USAGE ON SCHEMA cdb_geocoder_server TO geocoder_api;
    GRANT USAGE ON SCHEMA public TO geocoder_api;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO geocoder_api;
END$$;