# Quickstart

If you are using the set of APIs and libraries that CartoDB offers, and you are handling your data with the SQL API, you can make your data visible in your maps by geocoding the dataset programatically.

Here is an example of how to geocode a single country:

```bash
https://{username}.cartodb.com/api/v2/sql?q=SELECT cdb_geocode_admin0_polygon('USA')&api_key={Your API key}
```

In order to geocode an existent CartoDB dataset, an SQL UPDATE statement must be used to populate the geometry column in the dataset with the results of the Geocoding API. For example, if the column where you are storing the country names for each one of our rows is called `country_column`, run the following statement in order to geocode the dataset:

```bash
https://{username}.cartodb.com/api/v2/sql?q=UPDATE {tablename} SET the_geom = cdb_geocode_admin0_polygon({country_column})&api_key={Your API key}
```

Notice that you can make use of Postgres or PostGIS functions in your Geocoder API requests, as the result of it will be a geometry that can be handled by the system. As an example, if you need to retrieve the centroid of a specific country, you can wrap the resulting geometry from the Geocoder API inside the PostGIS `ST_Centroid` function:

```bash
https://{username}.cartodb.com/api/v2/sql?q=SELECT ST_Centroid(cdb_geocode_admin0_polygon('USA'))&api_key={Your API key}
```
