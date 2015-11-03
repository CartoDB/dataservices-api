CREATE OR REPLACE FUNCTION cdb_geocoder.CDBG_version()
RETURNS text AS $$
  SELECT '0.1.0'::text;
$$ language 'sql' IMMUTABLE STRICT;

