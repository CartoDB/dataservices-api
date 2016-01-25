# geocoder-api
The CartoDB Geocoder SQL API (server and client FTM)

### Deploy instructions
Steps to deploy a new Geocoder API version :

- Deploy new version of geocoder API to all servers
- Update the server user using: ALTER EXTENSION cdb_geocoder_server UPDATE TO '<CURRENT_VERSION>';
- Update the python dependencies if needed: **cartodb_geocoder** and **heremaps**
- Add the needed config in the `cdb_conf` table:
  - `redis_metadata_config` and `redis_metrics_conf`
    - `{"sentinel_host": "localhost", "sentinel_port": 26739, "sentinel_master_id": "mymaster", "timeout": 0.1, "redis_db": 5}`
  - `heremaps_conf`
    - `{"app_id": "APP_ID", "app_code": "APP_CODE"}`
- Deploy the client to all the servers with the new version
- Deploy the editor with the new geocoder api version changed (https://github.com/CartoDB/cartodb/blob/master/app/models/user/db_service.rb#L18)
- Execute the rails task to update first the CartoDB team organizaton to test in production
  - `RAILS_ENV=production bundle exec rake cartodb:db:configure_geocoder_extension_for_organizations['team']`
- Check if all works perfectly for our team. If so, execute the rake tasks to update all the users and organizations:
  - `RAILS_ENV=production bundle exec rake cartodb:db:configure_geocoder_extension_for_organizations['', true]`
  - `RAILS_ENV=production bundle exec rake cartodb:db:configure_geocoder_extension_for_non_org_users['', true]`
