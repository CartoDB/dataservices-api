--
-- Get username function
--
-- The purpose of this function is to retrieve the username from
-- a) schema where he/her is the owner in case is an organization user
-- b) entity_name from the cdb_conf database in case is a non organization user

CREATE OR REPLACE FUNCTION cdb_geocoder_client._cdb_username()
RETURNS text AS $$
DECLARE
  is_organization boolean;
  username text;
BEGIN
    SELECT cartodb.cdb_conf_getconf('user_config')->'is_organization' INTO is_organization;
    IF is_organization IS NULL THEN
        RAISE EXCEPTION 'User must have user configuration in the config table';
    ELSIF is_organization = TRUE THEN
        SELECT nspname
        FROM pg_namespace s
        LEFT JOIN pg_roles r ON s.nspowner = r.oid
        WHERE r.rolname = session_user INTO username;
    ELSE
        SELECT cartodb.cdb_conf_getconf('user_config')::json->'entity_name' INTO username;
    END IF;
    RETURN username;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;