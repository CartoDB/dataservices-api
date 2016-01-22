CREATE OR REPLACE FUNCTION cdb_geocoder_client._cdb_geocode_admin0_polygon (username text, organization_name text, country_name text)
RETURNS Geometry AS $$
  CONNECT cdb_geocoder_client._server_conn_str();
  SELECT cdb_geocoder_server.cdb_geocode_admin0_polygon (username, organization_name, country_name);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_geocoder_client._cdb_geocode_admin1_polygon (username text, organization_name text, admin1_name text)
RETURNS Geometry AS $$
  CONNECT cdb_geocoder_client._server_conn_str();
  SELECT cdb_geocoder_server.cdb_geocode_admin1_polygon (username, organization_name, admin1_name);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_geocoder_client._cdb_geocode_admin1_polygon (username text, organization_name text, admin1_name text, country_name text)
RETURNS Geometry AS $$
  CONNECT cdb_geocoder_client._server_conn_str();
  SELECT cdb_geocoder_server.cdb_geocode_admin1_polygon (username, organization_name, admin1_name, country_name);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_geocoder_client._cdb_geocode_namedplace_point (username text, organization_name text, city_name text)
RETURNS Geometry AS $$
  CONNECT cdb_geocoder_client._server_conn_str();
  SELECT cdb_geocoder_server.cdb_geocode_namedplace_point (username, organization_name, city_name);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_geocoder_client._cdb_geocode_namedplace_point (username text, organization_name text, city_name text, country_name text)
RETURNS Geometry AS $$
  CONNECT cdb_geocoder_client._server_conn_str();
  SELECT cdb_geocoder_server.cdb_geocode_namedplace_point (username, organization_name, city_name, country_name);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_geocoder_client._cdb_geocode_namedplace_point (username text, organization_name text, city_name text, admin1_name text, country_name text)
RETURNS Geometry AS $$
  CONNECT cdb_geocoder_client._server_conn_str();
  SELECT cdb_geocoder_server.cdb_geocode_namedplace_point (username, organization_name, city_name, admin1_name, country_name);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_geocoder_client._cdb_geocode_postalcode_polygon (username text, organization_name text, postal_code text, country_name text)
RETURNS Geometry AS $$
  CONNECT cdb_geocoder_client._server_conn_str();
  SELECT cdb_geocoder_server.cdb_geocode_postalcode_polygon (username, organization_name, postal_code, country_name);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_geocoder_client._cdb_geocode_postalcode_point (username text, organization_name text, postal_code text, country_name text)
RETURNS Geometry AS $$
  CONNECT cdb_geocoder_client._server_conn_str();
  SELECT cdb_geocoder_server.cdb_geocode_postalcode_point (username, organization_name, postal_code, country_name);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_geocoder_client._cdb_geocode_ipaddress_point (username text, organization_name text, ip_address text)
RETURNS Geometry AS $$
  CONNECT cdb_geocoder_client._server_conn_str();
  SELECT cdb_geocoder_server.cdb_geocode_ipaddress_point (username, organization_name, ip_address);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_geocoder_client._cdb_geocode_street_point (username text, organization_name text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS Geometry AS $$
  CONNECT cdb_geocoder_client._server_conn_str();
  SELECT cdb_geocoder_server.cdb_geocode_street_point (username, organization_name, searchtext, city, state_province, country);
$$ LANGUAGE plproxy;

