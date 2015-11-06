-- Check that check_host is working
select cdb_geocoder_server._check_host('cartodb.com');

-- Check that check_pwd is working
select cdb_geocoder_server._pwd();
