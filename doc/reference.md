# Geocoding functions

The following geocoding functions are available, grouped by categories.


## Country geocoder

This function provides a country geocoding service. It recognizes the names of the different countries from different synonyms, such as their English name, their endonym, or their ISO2 or ISO3 codes.

### cdb_geocode_admin0_polygon(_country_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`country_name` | `text` | Name of the country

#### Returns

Geometry (polygon, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_admin0_polygon('France')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_admin0_polygon({country_column})
```


## Level-1 Administrative regions geocoder

The following functions provide a geocoding service for administrative regions of level 1 (or NUTS-1) such as states for the United States, regions in France or autonomous communities in Spain.

### cdb_geocode_admin1_polygon(_admin1_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`admin1_name` | `text` | Name of the province/state

#### Returns

Geometry (polygon, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_admin1_polygon('Alicante')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_admin1_polygon({province_column})
```

### cdb_geocode_admin1_polygon(_admin1_name text, country_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`admin1_name` | `text` | Name of the province/state
`country_name` | `text` | Name of the country in which the province/state is located

#### Returns

Geometry (polygon, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_admin1_polygon('Alicante', 'Spain')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_admin1_polygon({province_column}, {country_column})
```


## City geocoder

The following functions provide a city geocoder service. It is recommended to use the more specific geocoding function -- the one that requires more parameters — in order for the result to be as accurate as possible when several cities share their name.

### cdb_geocode_namedplace_point(_city_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`city_name` | `text` | Name of the city

#### Returns

Geometry (point, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_namedplace_point('Barcelona')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_namedplace_point({city_column})
```

### cdb_geocode_namedplace_point(_city_name text, country_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`city_name` | `text` | Name of the city
`country_name` | `text` | Name of the country in which the city is located

#### Returns

Geometry (point, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_namedplace_point('Barcelona', 'Spain')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_namedplace_point({city_column}, 'Spain')
```

### cdb_geocode_namedplace_point(_city_name text, admin1_name text, country_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`city_name` | `text` | Name of the city
`admin1_name` | `text` | Name of the province/state in which the city is located
`country_name` | `text` | Name of the country in which the city is located

#### Returns

Geometry (point, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_namedplace_point('New York', 'New York', 'USA')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_namedplace_point({city_column}, {province_column}, 'USA')
```

## Postal codes geocoder

The following functions provide a postal code geocoding service that can be used to obtain points or polygon results. The postal code polygon geocoder covers the United States, France, Australia and Canada; a request for a different country will return an empty response.

### cdb_geocode_postalcode_polygon(_postal_code text, country_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`postal_code` | `text` | Postal code
`country_name` | `text` | Name of the country in which the postal code is located

#### Returns

Geometry (polygon, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_postalcode_polygon('11211', 'USA')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_postalcode_polygon({postal_code_column}, 'USA')
```

**Note:** For the USA, US Census ZCTAs are considered.

### cdb_geocode_postalcode_point(_code text, country_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`postal_code` | `text` | Postal code
`country_name` | `text` | Name of the country in which the postal code is located

#### Returns

Geometry (point, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_postalcode_point('11211', 'USA')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_postalcode_point({postal_code_column}, 'USA')
```

## IP addresses geocoder

This function provides an IP address geocoding service, for both IPv4 and IPv6 addresses.

### cdb_geocode_ipaddress_point(_ip_address text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`ip_address` | `text` | Postal code
`country_name` | `text` | IPv4 or IPv6 address

#### Returns

Geometry (point, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_ipaddress_point('102.23.34.1')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_ipaddress_point('102.23.34.1')
```
## Street-level geocoder

This function provides a street-level geocoding service. This service uses the street level geocoder defined for the user (currently, only the Here geocoder is available).

**This service is subject to quota limitations, and extra fees may apply.** Please view our [terms and conditions](https://cartodb.com/terms/)

Be mindful of the following when using this function:

  - **One credit per function call will be consumed**, and the results are not cached. If the query applies to a N rows dataset, then N credits will be used.
  - You are discouraged from using dynamic queries to the Geocoder API in your maps. This can result in credits consumption per map view. Note: **queries to the Geocoder API in your maps may be forbidden in the future**.
  - You are advised to store results of Geocoder API queries into your datasets and refresh them as needed, so that you can have finer control on your credits' usage.

### cdb_geocode_street_point(_search_text text, [city text], [state text], [country text]_)

#### Arguments

Name | Type | Description
--- | --- | ---
`searchtext` | `text` | searchtext contains free-form text containing address elements. You can specify the searchtext parameter by itself, or you can specify it with other parameters to narrow your search. For example, you can specify the state or country parameters, along with a free-form address in the searchtext field.
`city` | `text` | (Optional) Name of the city
`state` | `text` | (Optional) Name of the state
`country` | `text` | (Optional) Name of the country

#### Returns

Geometry (point, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_street_point('651 Lombard Street, San Francisco, California, United States')
SELECT cdb_geocode_street_point('651 Lombard Street', 'San Francisco')
SELECT cdb_geocode_street_point('651 Lombard Street', 'San Francisco', 'California')
SELECT cdb_geocode_street_point('651 Lombard Street', 'San Francisco', 'California', 'United States')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_street_point({street_name_column})
```
# Routing functions

The following rouging functions are available, grouped by categories.

## Isolines

This function provides an isolines generator sirves based on time or distance.

### cdb_isodistance(_source geometry, mode text, range integer[], options text[]_)

#### Arguments

Name | Type | Description | Accepted values
--- | --- | --- | ---
`source` | `geometry` | Source point, in 4326 projection, taken as the start point
`mode` | `geometry` | Type of transport used to calculate the isolines. | `car` and `walk`
`range` | `integer[]` | Range of the isoline in meters
`options` | `text[]` | Multiple options to add more capabilities to the analysis. See the options section to know more.

#### Options

The options values must be pass in the following way: `option=value`.

Name | Type | Description | Accepted values
--- | --- | --- | ---
`is_destination` | `boolean` | If is true the source point is the destination instead of the starting one.
`mode_type` | `text` | Type of route calculation | `shortest` or `fastest`. By default is `shortest`
`mode_traffic` | `text` | Use the traffic data to calculate the route. | `enabled` or `disabled`. By default is `disabled`
`singlecomponent` | `boolean` | If set to true the isoline service will always return single polygon, instead of creating a separate polygon for each ferry separated island. | `true` or `false`. Default value is false. 
`resolution` | `text` | Allows to specify level of detail needed for the isoline polygon. Unit is meters per pixel. Higher resolution may cause increased response time from the service.
`maxpoints` | `text` | Allows to limit amount of points in the returned isoline. If isoline consists of multiple components, sum of points from all components is considered. Each component will have at least 2 points, so it is possible that more points than maxpoints value will be returned. This is in case when 2 * number of components is higher than maxpoints. Enlarging number of maxpoints may cause increased response time from the service.
`quality` | `text` | Allows to reduce the quality of the isoline in favor of the response time. | `1`, `2`, `3`. Default value is 1 and it is the best quality.

#### Returns

Name | Type | Description
--- | --- | ---
`center` | `geometry` | Source point, in 4326 projection, taken as the start point
`data_range` | `integer` | The range that belongs to the generated isoline. 
`the_geom` | `geometry (multipolygon)` | Geometry of the generated isoline in 4326 projection. 

#### Example

##### Select

```bash
SELECT cdb_isodistance('010100000000000000008006C00DEB9D3C72F44340', 'car', ARRAY[1000,2000]::integer[]);
SELECT cdb_isodistance('010100000000000000008006C00DEB9D3C72F44340', 'walk', ARRAY[1000]::integer[], ARRAY['mode_traffic=enabled,quality=3']::text[]);
```

### cdb_isochrone(_source geometry, mode text, range integer[], options text[]_)

This function uses the same parameters and info as the `cdb_isodistance` function with the difference that the range is measured in seconds instead of meters

#### Example

##### Select

```bash
SELECT cdb_isochrone('010100000000000000008006C00DEB9D3C72F44340', 'car', ARRAY[300,900,12000]::integer[]);
SELECT cdb_isodistance('010100000000000000008006C00DEB9D3C72F44340', 'walk', ARRAY[300,900]::integer[], ARRAY['mode_traffic=enabled,quality=3']::text[]);
```
