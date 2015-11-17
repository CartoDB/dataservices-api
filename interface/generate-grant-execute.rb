#!/usr/bin/env ruby

# A script to automatically generate SQL files from an interface definition.

require 'csv'
require 'erb'

GEOCODER_CLIENT_SCHEMA = 'cdb_geocoder_client'
INTERFACE_SOURCE_FILE = 'interface.csv'

class GrantExecute
  TEMPLATE_FILE = 'templates/grant-execute.erb'

  attr_reader :function_signature

  def initialize(function_signature)
    @function_signature = function_signature
    @template = File.read(TEMPLATE_FILE)
  end

  def render
    ERB.new(@template).result(binding)
  end  
end

class PublicFunctionDefinition
  TEMPLATE_FILE = 'templates/public-function-definition.erb'

  attr_reader :function_signature

  def initialize(function_signature)
    @function_signature = function_signature
    @template = File.read(TEMPLATE_FILE)
  end

  def render
    ERB.new(@template).result(binding)
  end
end


CSV.foreach(INTERFACE_SOURCE_FILE, {headers: true}) do |function_signature|

  function_definition = PublicFunctionDefinition.new(function_signature).render
  puts function_definition


  grant = GrantExecute.new(function_signature).render
  #puts grant
end
