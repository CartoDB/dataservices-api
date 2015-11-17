#!/usr/bin/env ruby

# A script to automatically generate SQL files from an interface definition.

require 'csv'
require 'erb'

GEOCODER_CLIENT_SCHEMA = 'cdb_geocoder_client'
INTERFACE_SOURCE_FILE = 'interface.csv'

class GrantExecute
  TEMPLATE=<<-END
GRANT EXECUTE ON FUNCTION <%= GEOCODER_CLIENT_SCHEMA %>.<%= function_signature['function_name'] %>(<%= function_signature['argument_data_types'] %>) TO publicuser;
END

  attr_reader :function_signature

  def initialize(function_signature)
    @function_signature = function_signature
  end

  def render
    ERB.new(TEMPLATE).result(binding)
  end  
end



CSV.foreach(INTERFACE_SOURCE_FILE, {headers: true}) do |function_signature|
  grant = GrantExecute.new(function_signature).render
  puts grant
end
