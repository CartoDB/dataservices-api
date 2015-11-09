CREATE OR REPLACE FUNCTION geocode_admin0_polygons(search text)
    RETURNS SETOF Geometry AS $$
BEGIN
    RETURN QUERY SELECT geocode_admin0_polygons(search, session_user, txid_current());
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION geocode_admin0_polygons(search text, user_id name, tx_id bigint)
RETURNS Geometry AS $$
	CONNECT 'dbname=cartodb_dev_user_274bf952-8568-4598-9efd-be92ed3d2ead_db user=postgres';
    SELECT geom FROM geocode_admin0(search, tx_id, user_id);
$$ LANGUAGE plproxy;