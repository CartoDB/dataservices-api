# CARTO Data Services API client extension
Postgres extension for the CARTO Data Services API, client side.

## Dependencies
This extension is thought to be used on top of CartoDB geocoder extension, for the multiples available geocoders (internal, nokia, etc). 

The following is a non-comprehensive list of dependencies:

- Postgres 9.3+
- Postgis extension
- Schema triggers extension
- cartodb-postgresql CARTO extension

## Installation into the db cluster
This requires root privileges
```
sudo make all install
```

## Execute tests
```
PGUSER=postgres make installcheck
```

## Build, install & test
One-liner:
```
sudo PGUSER=postgres make all install installcheck
```

## Install onto a CARTO user's database

```
psql -U postgres cartodb_dev_user_fe3b850a-01c0-48f9-8a26-a82f09e9b53f_db
```

and then:

```sql
CREATE EXTENSION cdb_dataservices_client;
```

The extension creation in the user's db requires **superuser** privileges.

## User configuration

```
-- Point to the dataservices server DB (you can use a specific database for the server or your same user's):
SELECT CDB_Conf_SetConf('geocoder_server_config', '{ "connection_str": "host=localhost port=5432 dbname=<SERVER_DB_NAME> user=postgres"}');

SELECT CDB_Conf_SetConf('user_config', '{"is_organization": false, "entity_name": "<YOUR_USERNAME>"}');
```
