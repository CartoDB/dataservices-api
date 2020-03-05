
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_get_rate_limit(
  username TEXT,
  orgname TEXT,
  service TEXT)
RETURNS JSON AS $$
  import json
  from cartodb_services.config import ServiceConfiguration, RateLimitsConfigBuilder

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_config = ServiceConfiguration(service, username, orgname)
  rate_limit_config = RateLimitsConfigBuilder(service_config.server, service_config.user, service_config.org, service=service, username=username, orgname=orgname).get()
  if rate_limit_config.is_limited():
      return json.dumps({'limit': rate_limit_config.limit, 'period': rate_limit_config.period})
  else:
      return None
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_set_user_rate_limit(
  username TEXT,
  orgname TEXT,
  service TEXT,
  rate_limit_json JSON)
RETURNS VOID AS $$
  import json
  from cartodb_services.config import RateLimitsConfig, RateLimitsConfigSetter

  import cartodb_services
  cartodb_services.init(plpy, GD)

  config_setter = RateLimitsConfigSetter(service=service, username=username, orgname=orgname)
  if rate_limit_json:
      rate_limit = json.loads(rate_limit_json)
      limit = rate_limit.get('limit', None)
      period = rate_limit.get('period', None)
  else:
      limit = None
      period = None
  config = RateLimitsConfig(service=service, username=username, limit=limit, period=period)
  config_setter.set_user_rate_limits(config)
$$ LANGUAGE @@plpythonu@@ VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_set_org_rate_limit(
  username TEXT,
  orgname TEXT,
  service TEXT,
  rate_limit_json JSON)
RETURNS VOID AS $$
  import json
  from cartodb_services.config import RateLimitsConfig, RateLimitsConfigSetter

  import cartodb_services
  cartodb_services.init(plpy, GD)

  config_setter = RateLimitsConfigSetter(service=service, username=username, orgname=orgname)
  if rate_limit_json:
      rate_limit = json.loads(rate_limit_json)
      limit = rate_limit.get('limit', None)
      period = rate_limit.get('period', None)
  else:
      limit = None
      period = None
  config = RateLimitsConfig(service=service, username=username, limit=limit, period=period)
  config_setter.set_org_rate_limits(config)
$$ LANGUAGE @@plpythonu@@ STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_service_set_server_rate_limit(
  username TEXT,
  orgname TEXT,
  service TEXT,
  rate_limit_json JSON)
RETURNS VOID AS $$
  import json
  from cartodb_services.config import RateLimitsConfig, RateLimitsConfigSetter

  import cartodb_services
  cartodb_services.init(plpy, GD)

  config_setter = RateLimitsConfigSetter(service=service, username=username, orgname=orgname)
  if rate_limit_json:
      rate_limit = json.loads(rate_limit_json)
      limit = rate_limit.get('limit', None)
      period = rate_limit.get('period', None)
  else:
      limit = None
      period = None
  config = RateLimitsConfig(service=service, username=username, limit=limit, period=period)
  config_setter.set_server_rate_limits(config)
$$ LANGUAGE @@plpythonu@@ VOLATILE PARALLEL UNSAFE;
