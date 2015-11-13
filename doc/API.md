## Geocoder API

### Overview
### Quickstart
### General concepts
The Geocoder API offers geocoding services on top of the CartoDB SQL API by means of a set of geocoding functions. Each one of these functions is oriented to one kind of geocoding operation and it will return the corresponding geometry (a `polygon` or a `point`) according to the input information.

The Geocoder API decouples the geocoding service from the CartoDB Editor, and allows to geocode data (being single rows, complete datasets or simple inputs) programatically. 

#### Errors
Errors will be described in the response of the geocoder request. An example is as follows:

  ```json
  {
     error: [
          "function geocode_countries(text) does not exist"
     ]
  }
  ```

Due to the fact that the Geocoder API is used on top of the CartoDB SQL API you can check the [Making calls to the SQL API](http://docs.cartodb.com/cartodb-platform/sql-api/making-calls/) section to help you debug your SQL errors.

#### Pre/post conditions

#### Possible side-effects
The Geocoder API can return different types of geometries as result of different geocoding processes. The CartoDB platform does not support multigeometry layers or datasets, therefore the final users of this Geocoder API must check that they are using consistent geometry types inside a table to avoid further conflicts in the map visualization.

For each function:
function names
function parameters and types 
return type for the functions  (Geometry or NULL if not found, with SRID 4326)

### Reference
#### Geocoding functions
##### Country geocoder functions
###### geocode_admin0_polygon
* Description:
 This function receives a country name and returns a polygon geometry (SRID 4326) for the corresponding input.
* Functions:
  * `geocode_admin0_polygon(country_name text)`
     * **Parameters**: A text parameter with the name of the country to geocode.
     * **Return type:** `polygon`
     * **Usage example:**
       `````
      SELECT geocode_admin0_polygon('France')
      `````

#### Level-1 Administrative regions geocoder
###### geocode_admin1_polygon
* Functions: 
  * `geocode_admin1_polygon(admin1_name text)`
    * **Parameters**: 
    * **Return type:** `polygon`
    * **Usage example:**
      `````
      SELECT geocode_admin1_polygon('Alicante')
      `````

  *  `geocode_admin1_polygon(admin1_name text, country_name text)`
    * **Parameters**: 
    * **Return type:** `polygon`
    * **Usage example:**
      `````
      SELECT geocode_admin1_polygon('Alicante', 'Spain')
      `````

#### City geocoder
##### geocode_namedplace_point
* Functions:
  *  `geocode_namedplace_point(city_name text)`
    * **Parameters**: 
    * **Return type:** `point`
    * **Usage example:**
      `````
      SELECT geocode_namedplace_point('Barcelona')
      `````

  *  `geocode_namedplace_point(city_name text, country_name text)`
    * **Parameters**: 
    * **Return type:** `point`
    * **Usage example:**
      `````
      SELECT geocode_namedplace_point('Barcelona', 'Spain')
      `````

  *  `geocode_namedplace_point(city_name text, admin1_name text, country_name text)`
    * **Parameters**: 
    * **Return type:** `point`
    * **Usage example:**
      `````
      SELECT geocode_namedplace_point('New York', 'New York', 'USA')
      `````

#### Postal codes geocoder
##### geocode_postalcode_polygon
* Functions:
  * `geocode_postalcode_polygon(code text, country_name text)`
    * **Parameters**: 
    * **Return type:** `polygon`
    * **Usage example:**
        `````
      SELECT geocode_postalcode_polygon('11211', 'USA')
      `````

##### geocode_postalcode_point
* Functions:
  * `geocode_postalcode_point(code text, country_name text)`
    * **Parameters**: 
    * **Return type:** `point`
    * **Usage example:**
        `````
      SELECT geocode_postalcode_point('11211', 'USA')
      `````

#### IP addresses Geocoder
##### geocode_ip_point(ipaddress text)
* Functions:
  * `geocode_ip_point(ipaddress text)`
    * **Parameters**: 
    * **Return type:** `point`
    * **Usage example:**
        `````
      SELECT geocode_ip_point('102.23.34.1')
      `````








