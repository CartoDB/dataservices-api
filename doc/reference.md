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

```sql
SELECT cdb_geocode_admin0_polygon('France')
```

##### Update

```sql
UPDATE {tablename} SET {the_geom} = cdb_geocode_admin0_polygon({country_column})
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

```sql
SELECT cdb_geocode_admin1_polygon('Alicante', 'Spain')
```

##### Update

```sql
UPDATE {tablename} SET the_geom = cdb_geocode_admin1_polygon({province_column}, {country_column})
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

```sql
SELECT cdb_geocode_admin1_polygon('Alicante', 'Spain')
```

##### Update

```sql
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

```sql
SELECT cdb_geocode_namedplace_point('Barcelona')
```

##### Update

```sql
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

```sql
SELECT cdb_geocode_namedplace_point('Barcelona', 'Spain')
```

##### Update

```sql
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

```sql
SELECT cdb_geocode_namedplace_point('New York', 'New York', 'USA')
```

##### Update

```sql
UPDATE {tablename} SET the_geom = cdb_geocode_namedplace_point({city_column}, {province_column}, 'Spain')
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

```sql
SELECT cdb_geocode_postalcode_polygon('11211', 'USA')
```

##### Update

```sql
UPDATE {tablename} SET the_geom = cdb_geocode_postalcode_polygon({postal_code_column}, 'Spain')
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

```sql
SELECT cdb_geocode_postalcode_point('11211', 'USA')
```

##### Update

```sql
UPDATE {tablename} SET the_geom = cdb_geocode_postalcode_point({postal_code_column}, 'United States')
```

## IP addresses Geocoder

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

```sql
SELECT cdb_geocode_ipaddress_point('102.23.34.1')
```

##### Update

```sql
UPDATE {tablename} SET the_geom = cdb_geocode_ipaddress_point('102.23.34.1')
```
