## Geocoder API

### Overview
### Quickstart
### General concepts
### Reference
#### Free geocoding functions

 ##### geocode_admin0_polygon(countryname text)
 ##### geocode_admin1_polygon(adminname text)
 ##### geocode_admin1_polygon(adminname text, countryname text)
 ##### geocode_namedplace_point(city text)
 ##### geocode_namedplace_point(city text, country text)
 ##### geocode_namedplace_point(city text, admin1 text, country text)
 ##### geocode_postalcode_polygon(code text, country text)
 ##### geocode_postalcode_point(code text, country text)
 ##### geocode_ip_point(ipaddress text)


 For each function:
function names
function parameters and types (most of them are text params)
return type for the functions  (Geometry or NULL if not found, with SRID 4326)
a description of the handling of any error condition
pre- and post-conditions or invariants
possible side-effects



### Country geocoder
* Description:

  This function receives a country name and returns a polygon geometry (SRID 4326) for the corresponding input.
* Functions:
  * `geocode_admin0_polygons(countryname text)`
     * **Return type:** `polygon`
     * **Usage example:**
       `````
      SELECT geocode_admin0_polygons('France')
      `````

### Level-1 Administrative regions geocoder
* Functions: 
  * `geocode_admin1_polygons(adminname text)`
    *  **Return type:** `polygon`
    * **Usage example:**
      `````
      SELECT geocode_admin1_polygons('Alicante')
      `````

  *  `geocode_admin1_polygons(adminname text, countryname text)`
    *  **Return type:** `polygon`
    * **Usage example:**
      `````
      SELECT geocode_admin1_polygons('Alicante', 'Spain')
      `````

### Cities geocoder
* Functions:
  *  `geocode_namedplace(city text)`
    * **Return type:** `point`
    * **Usage example:**
      `````
      SELECT geocode_namedplace('Barcelona')
      `````

  *  `geocode_namedplace(city text, country text)`
     * **Return type:** `point`
      * **Usage example:**
        `````
      SELECT geocode_namedplace('Barcelona', 'Spain')
      `````

  *  `geocode_namedplace(city text, admin1 text, country text)`
      * **Return type:** `point`
      * **Usage example:**
        `````
      SELECT geocode_namedplace('New York', 'New York', 'USA')
      `````

### Postal codes geocoder
* Functions:
  * `geocode_postalcode_polygons(code text, country text)`
    * **Return type:** `polygon`
    * **Usage example:**
        `````
      SELECT geocode_postalcode_polygons('11211', 'USA')
      `````

  * `geocode_postalcode_polygons(code text)` **PROBABLY WE DON'T WANT TO PUBLISH THIS ONE**
    * **Return type:** `polygon` 
    * **Usage example:**
      `````
      SELECT geocode_postalcode_polygons('11211')
      `````

  * `geocode_postalcode_points(code text, country text)`
    * **Return type:** `point`
    * **Usage example:**
        `````
      SELECT geocode_postalcode_points('11211', 'USA')
      `````

  * `geocode_postalcode_points(code integer, country text)`
    * **Return type:** `point`
    * **Usage example:**
        `````
      SELECT geocode_postalcode_points(11211, 'USA')
      `````

  * `geocode_postalcode_points(code text)`
    * **Return type:** `point`
    * **Usage example:**
        `````
      SELECT geocode_postalcode_points('11211')
      `````


### IP addresses Geocoder
* Functions:
  * `geocode_ip(ipaddress text)`
    * **Return type:** `point`
    * **Usage example:**
        `````
      SELECT geocode_ip('102.23.34.1')
      `````
