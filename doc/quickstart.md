# Quickstart

If you are using the set of APIs and libraries that CartoDB offers, and you are handling your data with the SQL API, you can make your data visible in your maps by geocoding the dataset programatically. The set of isoline functions allow you to calculate the area which can be reached by travelling a given distance or time, useful for geospatial analysis, such as Trade Area Analysis.

Here is an example of how to geocode a single country:

```bash
https://{username}.cartodb.com/api/v2/sql?q=SELECT cdb_geocode_admin0_polygon('USA')&api_key={Your API key}
```

In order to geocode an existent CartoDB dataset, an SQL UPDATE statement must be used to populate the geometry column in the dataset with the results of the Geocoding API. For example, if the column where you are storing the country names for each one of our rows is called `country_column`, run the following statement in order to geocode the dataset:

```bash
https://{username}.cartodb.com/api/v2/sql?q=UPDATE {tablename} SET the_geom = cdb_geocode_admin0_polygon({country_column})&api_key={Your API key}
```
You can use the isoline functions to retrieve, for example, isochrone lines from a certain location, specifying the mode and the ranges that will define each of the isolines. The following query calculates isolines for areas that are 5, 10 and 15 minutes (300, 600 and 900 seconds, respectively) away from the location by following a path defined by car routing.

```bash
https://{username}.cartodb.com/api/v2/sql?q=SELECT cdb_isochrone('POINT(-3.70568 40.42028)'::geometry, 'car', ARRAY[300,600,900]::integer[])&api_key={Your API key}
```

Notice that you can make use of Postgres or PostGIS functions in your Data Services API requests, as the result is a geometry that can be handled by the system. For example, suppose you need to retrieve the centroid of a specific country, you can wrap the resulting geometry from the geocoder functions inside the PostGIS `ST_Centroid` function:

```bash
https://{username}.cartodb.com/api/v2/sql?q=SELECT ST_Centroid(cdb_geocode_admin0_polygon('USA'))&api_key={Your API key}
```

## Using Mapzen for Geocoding and Routing

You can use Mapzen as the [geocoder service provider](http://docs.cartodb.com/cartodb-platform/dataservices-api/#geocoding-functions) with CartoDB. You can also use the [Mapzen API](https://mapzen.com/documentation/search/) directly, to geocode your data. Additionally, the Mapzen routing service is built into the [routing functions](http://docs.cartodb.com/cartodb-platform/dataservices-api/#routing-functions) of CartoDB.
