# Rate limits

Services can be rate-limited. (currently only gecoding with Mapzen or Here providers is limited)

The rate limits configuration can be established at server, organization or user levels, the latter having precedence over the earlier.

The default configuration (a null or empty configuration) doesn't impose any limits.

The configuration consist of a JSON object with two attributes:

* `period`: the rate-limiting period, in seconds.
* `limit`: the maximum number of request in the established period.

If a service request exceeds the configured rate limits
(i.e. if more than `limit` calls are performe in a fixed interval of
duration `period` seconds) the call will fail with an "Rate limit exceeded" error.

## Server-side interface

There's a server-side SQL interface to query or change the configuration.

### cdb_dataservices_server.cdb_service_get_rate_limit(username, orgname, service)

This function returns the rate limit configuration for a given user and service.

#### Returns

The result is a JSON object with the configuration (`period` and `limit` attributes as explained above).

### cdb_dataservices_server.cdb_service_set_user_rate_limit(username, orgname, service, rate_limit)

This function sets the rate limit configuration for the user. This overrides any other configuration.

The configuration is provided as a JSON literal. To remove the user-level configuration `NULL` should be passed as the `rate_limit`.

#### Returns

This functions doesn't return any value.

### cdb_dataservices_server.cdb_service_set_org_rate_limit(username, orgname, service, rate_limit)

This function sets the rate limit configuration for the organization.
This overrides server level configuration and is overriden by user configuration if present.

The configuration is provided as a JSON literal. To remove the organization-level configuration `NULL` should be passed as the `rate_limit`.

#### Returns

This functions doesn't return any value.

### cdb_dataservices_server.cdb_service_set_server_rate_limit(username, orgname, service, rate_limit)

This function sets the default rate limit configuration for all users accesing the dataservices server. This is overriden by organization of user configuration.

The configuration is provided as a JSON literal. To remove the organization-level configuration `NULL` should be passed as the `rate_limit`.

#### Returns

This functions doesn't return any value.

## Client-side interface

For convenience there's also a client-side interface (in the client dataservices-api extension), consisting
of public functions to get the current configuration and privileged functions to change it.

### Public functions

### cdb_dataservices_client.cdb_service_get_rate_limit(service)

This function returns the rate limit configuration for the specified service
and the user corresponding to the role which makes the calls.

#### Returns

The result is a JSON object with the configuration (`period` and `limit` attributes as explained above).

### Privileged function

Thes functions are not accessible by regular user roles, and the user and organization names must be provided as parameters.

### cdb_dataservices_client.cdb_service_set_user_rate_limit(username, orgname, service, rate_limit)

This function sets the rate limit configuration for the user. This overrides any other configuration.

The configuration is provided as a JSON literal. To remove the user-level configuration `NULL` should be passed as the `rate_limit`.

#### Returns

This functions doesn't return any value.

### cdb_dataservices_client.cdb_service_set_org_rate_limit(username, orgname, service, rate_limit)

This function sets the rate limit configuration for the organization.
This overrides server level configuration and is overriden by user configuration if present.

The configuration is provided as a JSON literal. To remove the organization-level configuration `NULL` should be passed as the `rate_limit`.

#### Returns

This functions doesn't return any value.

### cdb_dataservices_client.cdb_service_set_server_rate_limit(username, orgname, service, rate_limit)

This function sets the default rate limit configuration for all users accesing the dataservices server. This is overriden by organization of user configuration.

The configuration is provided as a JSON literal. To remove the organization-level configuration `NULL` should be passed as the `rate_limit`.

#### Returns

This functions doesn't return any value.
