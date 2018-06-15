CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_bulk_geocode_street_point (searchtext jsonb)
RETURNS SETOF cdb_dataservices_client.geocoding AS $$
DECLARE

  username text;
  orgname text;
BEGIN
  -- TODO: check
  -- TODO: bulk
  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_bulk_geocode_street_point(searchtext);
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE;
