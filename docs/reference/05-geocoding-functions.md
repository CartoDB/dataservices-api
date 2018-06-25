## Geocoding Functions

The [geocoder](https://carto.com/data/geocoder-api/) functions allow you to match your data with geometries on your map. This geocoding service can be used programatically to geocode datasets via the CARTO SQL API. It is fed from _Open Data_ and it serves geometries for countries, provinces, states, cities, postal codes, IP addresses and street addresses. CARTO provides functions for several different categories of geocoding through the Data Services API.

**Warning:** This service is subject to quota limitations and extra fees may apply. View the [Quota Information]({{site.dataservicesapi_docs}}/support/quota-information/) section for details and recommendations about to quota consumption.

The following example displays how to geocode a single country:

```bash
https://{username}.carto.com/api/v2/sql?q=SELECT cdb_geocode_admin0_polygon('USA')&api_key={api_key}
```

In order to geocode an existent CARTO dataset, an SQL UPDATE statement must be used to populate the geometry column in the dataset with the results of the Data Services API. For example, if the column where you are storing the country names for each one of our rows is called `country_column`, run the following statement in order to geocode the dataset:

```bash
https://{username}.carto.com/api/v2/sql?q=UPDATE {tablename} SET the_geom = cdb_geocode_admin0_polygon('USA')&api_key={api_key}
```

Notice that you can make use of Postgres or PostGIS functions in your Data Services API requests, as the result is a geometry that can be handled by the system. For example, suppose you need to retrieve the centroid of a specific country, you can wrap the resulting geometry from the geocoder functions inside the PostGIS `ST_Centroid` function:

```bash
https://{username}.carto.com/api/v2/sql?q=UPDATE {tablename} SET the_geom = ST_Centroid(cdb_geocode_admin0_polygon('USA'))&api_key={api_key}
```


The following geocoding functions are available, grouped by categories.

### Country Geocoder

This function geocodes your data into country border geometries. It recognizes the names of the different countries either by different synonyms (such as their English name or their endonym), or by ISO (ISO2 or ISO3) codes.

#### cdb_geocode_admin0_polygon(_country_name text_)

Geocodes the text name of a country into a country_name geometry, displayed as polygon data.

##### Arguments

Name | Type | Description
--- | --- | ---
`country_name` | `text` | Name of the country

##### Returns

Geometry (polygon, EPSG 4326) or null

### Example

#### Update the geometry of a table to geocode it

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_admin0_polygon({country_column})
```

#### Insert a geocoded row into a table
```bash
INSERT INTO {tablename} (the_geom) SELECT cdb_geocode_admin0_polygon('France')
```

### Level-1 Administrative Regions Geocoder

This function geocodes your data into polygon geometries for [Level 1](https://en.wikipedia.org/wiki/Table_of_administrative_divisions_by_country), or [NUTS-1](https://en.wikipedia.org/wiki/NUTS_1_statistical_regions_of_England), administrative divisions (or units) of countries. For example, a "state" in the United States, "départements" in France, or an autonomous community in Spain.

#### cdb_geocode_admin1_polygon(_admin1_name text_)

Geocodes the name of the province/state into a Level-1 administrative region, displayed as a polygon geometry.

##### Arguments

Name | Type | Description
--- | --- | ---
`admin1_name` | `text` | Name of the province/state

##### Returns

Geometry (polygon, EPSG 4326) or null

##### Example

###### Update the geometry of a table to geocode it

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_admin1_polygon({province_column})
```

###### Insert a geocoded row into a table

```bash
INSERT INTO {tablename} (the_geom) SELECT cdb_geocode_admin1_polygon('Alicante')
```


#### cdb_geocode_admin1_polygon(_admin1_name text, country_name text_)

Geocodes the name of the province/state for a specified country into a Level-1 administrative region, displayed as a polygon geometry.

##### Arguments

Name | Type | Description
--- | --- | ---
`admin1_name` | `text` | Name of the province/state
`country_name` | `text` | Name of the country in which the province/state is located

##### Returns

Geometry (polygon, EPSG 4326) or null

##### Example

###### Update the geometry of a table to geocode it

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_admin1_polygon({province_column}, {country_column})
```
###### Insert a geocoded row into a table

```bash
INSERT INTO {tablename} (the_geom) SELECT cdb_geocode_admin1_polygon('Alicante', 'Spain')
```


### City Geocoder

This function geocodes your data into point geometries for names of cities. It is recommended to use geocoding functions that require more defined parameters — this returns more accurate results when several cities have the same name. _If there are duplicate results for a city name, the city name with the highest population will be returned._

#### cdb_geocode_namedplace_point(_city_name text_)

Geocodes the text name of a city into a named place geometry, displayed as point data.

##### Arguments

Name | Type | Description
--- | --- | ---
`city_name` | `text` | Name of the city

##### Returns

Geometry (point, EPSG 4326) or null

##### Example

###### Select

###### Update the geometry of a table to geocode it

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_namedplace_point({city_column})
```

###### Insert a geocoded row into a table

```bash
INSERT INTO {tablename} (the_geom) SELECT cdb_geocode_namedplace_point('Barcelona')
```


#### cdb_geocode_namedplace_point(_city_name text, country_name text_)

Geocodes the text name of a city for a specified country into a named place point geometry.

##### Arguments

Name | Type | Description
--- | --- | ---
`city_name` | `text` | Name of the city
`country_name` | `text` | Name of the country in which the city is located

##### Returns

Geometry (point, EPSG 4326) or null

##### Example

###### Update the geometry of a table to geocode it

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_namedplace_point({city_column}, 'Spain')
```

###### Insert a geocoded row into a table

```bash
INSERT INTO {tablename} (the_geom) SELECT cdb_geocode_namedplace_point('Barcelona', 'Spain')
```


#### cdb_geocode_namedplace_point(_city_name text, admin1_name text, country_name text_)

Geocodes your data into a named place point geometry, containing the text name of a city, for a specified province/state and country. This is recommended for the most accurate geocoding of city data. 
##### Arguments

Name | Type | Description
--- | --- | ---
`city_name` | `text` | Name of the city
`admin1_name` | `text` | Name of the province/state in which the city is located
`country_name` | `text` | Name of the country in which the city is located

##### Returns

Geometry (point, EPSG 4326) or null

##### Example

###### Update the geometry of a table to geocode it

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_namedplace_point({city_column}, {province_column}, 'USA')
```

###### Insert a geocoded row into a table

```bash
INSERT INTO {tablename} (the_geom) SELECT cdb_geocode_namedplace_point('New York', 'New York', 'USA')
```

### Postal Code Geocoder

These functions geocode your data into point, or polygon, geometries for postal codes. The postal code geocoder covers the United States, France, Australia and Canada; a request for a different country will return an empty response.

**Note:** For the USA, US Census Zip Code Tabulation Areas (ZCTA) are used to reference geocodes for USPS postal codes service areas. This is not a CARTO restriction, this is a US Government licensing protection of their zip code data source; which is not publicly available. Additionally, zip codes are considered service areas and are not actually geometric areas. As a solution, the US Census provides ZCTA data, which tabulates GIS postal codes for USPS locations by aggregating census blocks. For details about how ZCTAs are created, see [ZIP Code™ Tabulation Areas (ZCTAs™)](https://www.census.gov/geo/reference/zctas.html). If you are geocoding data and your zip codes fail, ensure you are using ZCTAs for the postal code.

#### cdb_geocode_postalcode_polygon(_postal_code text, country_name text_)

Geocodes the postal code for a specified country into a **polygon** geometry.

##### Arguments

Name | Type | Description
--- | --- | ---
`postal_code` | `text` | Postal code
`country_name` | `text` | Name of the country in which the postal code is located

##### Returns

Geometry (polygon, EPSG 4326) or null

##### Example

###### Update the geometry of a table to geocode it

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_postalcode_polygon({postal_code_column}, 'USA')
```

###### Insert a geocoded row into a table

```bash
INSERT INTO {tablename} (the_geom) SELECT cdb_geocode_postalcode_polygon('11211', 'USA')
```

#### cdb_geocode_postalcode_point(_code text, country_name text_)

Geocodes the postal code for a specified country into a **point** geometry.

##### Arguments

Name | Type | Description
--- | --- | ---
`postal_code` | `text` | Postal code
`country_name` | `text` | Name of the country in which the postal code is located

##### Returns

Geometry (point, EPSG 4326) or null

##### Example

###### Update the geometry of a table to geocode it

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_postalcode_point({postal_code_column}, 'USA')
```

###### Insert a geocoded row into a table

```bash
INSERT INTO {tablename} (the_geom) SELECT cdb_geocode_postalcode_point('11211', 'USA')
```


### IP Addresses Geocoder

This function geocodes your data into point geometries for IP addresses. This is useful if you are analyzing location based data, based on a set of user's IP addresses.

#### cdb_geocode_ipaddress_point(_ip_address text_)

Geocodes a postal code from a specified country into an IP address, displayed as a point geometry.

##### Arguments

Name | Type | Description
--- | --- | ---
`ip_address` | `text` | IPv4 or IPv6 address

##### Returns

Geometry (point, EPSG 4326) or null

##### Example

###### Update the geometry of a table to geocode it

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_ipaddress_point('102.23.34.1')
```

###### Insert a geocoded row into a table

```bash
INSERT INTO {tablename} (the_geom) SELECT cdb_geocode_ipaddress_point('102.23.34.1')
```

### Street-Level Geocoder

This function geocodes your data into a point geometry for a street address. CARTO platform uses [Mapbox geocoding services](https://www.mapbox.com/) as the service provider for street-level geocoding. [Contact us](mailto:sales@carto.com) if you have any specific questions or requirements about the location data service provider being used with your account.

**This service is subject to quota limitations, and extra fees may apply**. View the [Quota information]({{site.dataservicesapi_docs}}/support/quota-information/) for details and recommendations about quota consumption.

#### cdb_geocode_street_point(_search_text text, [city text], [state text], [country text]_)

Geocodes a complete address into a single street geometry, displayed as point data.

##### Arguments

Name | Type | Description
--- | --- | --- | ---
`searchtext` | `text` | searchtext contains free-form text containing address elements. You can specify the searchtext parameter by itself, or with other parameters, to narrow your search. For example, you can specify the state or country parameters, along with a free-form address in the searchtext field.
`city` | `text` | (Optional) Name of the city.
`state` | `text` | (Optional) Name of the state.
`country` | `text` | (Optional) Name of the country.

##### Returns

Geometry (point, EPSG 4326) or null

##### Example

###### Update the geometry of a table to geocode it

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_street_point({street_name_column})
```

###### Insert a geocoded row into a table

```bash
INSERT INTO {tablename} (the_geom) SELECT cdb_geocode_street_point('651 Lombard Street', 'San Francisco', 'California', 'United States')
```
