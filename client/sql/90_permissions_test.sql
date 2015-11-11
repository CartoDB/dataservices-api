-- Use regular user role
SET ROLE test_regular_user;

-- Exercise the public function
-- it is public, it shall work
SELECT cdb_geocoder_client.geocode_admin0_polygons('Spain');

-- Check the regular user has no permissions on private functions
SELECT cdb_geocoder_client._geocode_admin0_polygons('evil_user', 666, 'Hell');

-- Check the regular user cannot look into config table
SELECT * from cdb_geocoder_client._config;
