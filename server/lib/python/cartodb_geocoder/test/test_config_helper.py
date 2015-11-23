from cartodb_geocoder import config_helper
from unittest import TestCase
from nose.tools import assert_raises


class TestConfigHelper(TestCase):

  def test_should_return_list_of_user_config_if_its_ok(self):
    user_config_json = '{"is_organization": false, "entity_name": "test_user"}'
    user_config = config_helper.UserConfig(user_config_json, 'development_cartodb_user_UUID')
    assert user_config.is_organization == False
    assert user_config.entity_name == 'test_user'
    assert user_config.user_id == 'UUID'

  def test_should_return_raise_config_exception_if_not_ok(self):
    user_config_json = '{"is_organization": "false"}'
    assert_raises(config_helper.ConfigException, config_helper.UserConfig, user_config_json)

  def test_should_return_raise_config_exception_if_empty(self):
    user_config_json = '{}'
    assert_raises(config_helper.ConfigException, config_helper.UserConfig, user_config_json)

  def test_should_return_list_of_nokia_geocoder_config_if_its_ok(self):
    geocoder_config_json = """{"street_geocoder_provider": "Nokia",
      "nokia_monthly_quota": 100, "nokia_soft_geocoder_limit": false}"""
    geocoder_config = config_helper.GeocoderConfig(geocoder_config_json)
    assert geocoder_config.nokia_geocoder == True
    assert geocoder_config.nokia_monthly_quota == 100
    assert geocoder_config.nokia_soft_limit == False

  def test_should_raise_configuration_exception_when_missing_nokia_geocoder_parameters(self):
    geocoder_config_json = '{"street_geocoder_provider": "NokiA", "nokia_monthly_quota": "100"}'
    assert_raises(config_helper.ConfigException, config_helper.GeocoderConfig, geocoder_config_json)

  def test_should_raise_configuration_exception_when_missing_nokia_geocoder_parameters_2(self):
    geocoder_config_json = '{"street_geocoder_provider": "NoKia", "nokia_soft_geocoder_limit": "false"}'
    assert_raises(config_helper.ConfigException, config_helper.GeocoderConfig, geocoder_config_json)

  def test_should_return_list_of_google_geocoder_config_if_its_ok(self):
    geocoder_config_json = """{"street_geocoder_provider": "gOOgle",
      "google_maps_private_key": "sdasdasda"}"""
    geocoder_config = config_helper.GeocoderConfig(geocoder_config_json)
    assert geocoder_config.google_geocoder == True
    assert geocoder_config.google_api_key ==  'sdasdasda'

  def test_should_raise_configuration_exception_when_missing_google_api_key(self):
    geocoder_config_json = '{"street_geocoder_provider": "google"}'
    assert_raises(config_helper.ConfigException, config_helper.GeocoderConfig, geocoder_config_json)