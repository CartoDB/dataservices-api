CREATE TYPE cdb_dataservices_client._entity_config AS (
    username text,
    organization_name text,
    apikey_permissions json
);

--
-- Get entity config function
--
-- The purpose of this function is to retrieve the username and organization name from
-- a) schema where he/her is the owner in case is an organization user
-- b) entity_name from the cdb_conf database in case is a non organization user
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_entity_config()
RETURNS record AS $$
DECLARE
    result cdb_dataservices_client._entity_config;
    apikey_config json;
    is_organization boolean;
    organization_name text DEFAULT NULL;
BEGIN
    SELECT cartodb.cdb_conf_getconf('api_keys_'||session_user) INTO apikey_config;

    SELECT cartodb.cdb_conf_getconf('user_config')->'is_organization' INTO is_organization;
    IF is_organization IS NULL THEN
        RAISE EXCEPTION 'User must have user configuration in the config table';
    ELSIF is_organization = TRUE THEN
        SELECT cartodb.cdb_conf_getconf('user_config')->>'entity_name' INTO organization_name;
    END IF;
    result.username = apikey_config->>'username';
    result.organization_name = organization_name;
    result.apikey_permissions = apikey_config->'permissions';
    RETURN result;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL SAFE
    SET search_path = pg_temp;

