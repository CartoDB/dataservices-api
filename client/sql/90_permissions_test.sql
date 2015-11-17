-- Use regular user role
SET ROLE test_regular_user;

-- Exercise the public function
-- it is public, it shall work
SELECT cdb_geocoder_client.geocode_admin0_polygon('Spain');
SELECT cdb_geocoder_client.geocode_admin1_polygon('California');
SELECT cdb_geocoder_client.geocode_admin1_polygon('California', 'United States');
SELECT cdb_geocoder_client.geocode_namedplace_point('Elx');
SELECT cdb_geocoder_client.geocode_namedplace_point('Elx', 'Valencia');
SELECT cdb_geocoder_client.geocode_namedplace_point('Elx', 'Valencia', 'Spain');
SELECT cdb_geocoder_client.geocode_postalcode_polygon('03204', 'Spain');
SELECT cdb_geocoder_client.geocode_postalcode_point('03204', 'Spain');
SELECT cdb_geocoder_client.geocode_ip('8.8.8.8');

-- Check the regular user has no permissions on private functions
SELECT cdb_geocoder_client._geocode_admin0_polygon('evil_user', 666, 'Hell');
SELECT cdb_geocoder_client._geocode_admin1_polygon('evil_user', 666, 'Hell');
SELECT cdb_geocoder_client._geocode_admin1_polygon('evil_user', 666, 'Sheol', 'Hell');
SELECT cdb_geocoder_client._geocode_namedplace_point('evil_user', 666, 'Sheol');
SELECT cdb_geocoder_client._geocode_namedplace_point('evil_user', 666, 'Sheol', 'Hell');
SELECT cdb_geocoder_client._geocode_namedplace_point('evil_user', 666, 'Sheol', 'Hell', 'Ugly world');
SELECT cdb_geocoder_client._geocode_postalcode_polygon('evil_user', 666, '66666', 'Hell');
SELECT cdb_geocoder_client._geocode_postalcode_point('evil_user', 666, '66666', 'Hell');
SELECT cdb_geocoder_client._geocode_ip('evil_user', 666, '8.8.8.8');
