# CartoDB geocoder API client extension
Postgres extension for the CartoDB geocoder API, client side.

## Dependencies
This extension is thought to be used on top of CartoDB geocoder extension, for the multiples available geocoders (internal, nokia, etc). 

The following is a non-comprehensive list of dependencies:

- Postgres 9.3+
- Postgis extension
- Schema triggers extension
- CartoDB extension

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

## Install onto a cartodb user's database

```
psql -U postgres cartodb_dev_user_fe3b850a-01c0-48f9-8a26-a82f09e9b53f_db
```

and then:

```sql
CREATE EXTENSION cdb_geocoder_client;
```

The extension creation in the user's db requires **superuser** privileges.
