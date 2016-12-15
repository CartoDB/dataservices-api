# Exception-Safe functions

The public API dataservices functions emit exceptions in general when an error occurs
or a limiting condition is met (e.g. quotas are exceeded).

For each public function `x` we have a internal function named `_x_exception_safe` which
acts as a wrapper to the public function, with the same signature, but captures
exceptions generated during its execution (except those due to incomplete configuration or
authentication issues) and returns NULL or empty set values in those cases.

## Intended Use

These functions are useful in cases when it is undesirable to rollback a transaction.
Fo example if a table is geocoded with:

```sql
UPDATE table SET the_geom=cdb_geocode_street_point(user,NULL,address,city,NULL,country);
```

In case of the user geocoding quota being exhausted mid-process, the user could
incur in external service expenses but any geocoded data would be lost due to the
transaction rollback.

We can avoid the problem using the corresponding exception-safe function:

```sql
UPDATE table SET the_geom=_cdb_geocode_street_point_exception_safe(user,NULL,address,city,NULL,country);
```

# Addition Information

See https://github.com/CartoDB/dataservices-api/issues/314 for more information.