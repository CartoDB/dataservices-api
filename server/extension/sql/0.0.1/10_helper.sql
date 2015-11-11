-- Get values_json for provided key from conf table
CREATE OR REPLACE FUNCTION cdb_geocoder_server._get_conf(_key TEXT)
  RETURNS text
AS $$
DECLARE
  rec RECORD;
BEGIN
  SELECT INTO rec values_json FROM conf WHERE conf.key = _key;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Missing key ''%'' in conf table', _key;
  END IF;

  RETURN rec.values_json;
END
$$ LANGUAGE plpgsql;
