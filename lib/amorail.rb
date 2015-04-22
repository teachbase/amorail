require 'amorail/version'
require 'amorail/config'
require 'amorail/client'
require 'amorail/exceptions'
require 'amorail/entity'
require 'amorail/property'

require 'amorail/entities/leadable'

Gem.find_files('amorail/entities/*.rb').each { |path| require path }

# AmoCRM API integration.
# https://www.amocrm.com/
module Amorail
  def self.config
    @config ||= Config.new
  end

  def self.properties
    @properties ||= Property.new(client)
  end

  def self.configure
    yield(config) if block_given?
  end

  def self.client
    @client ||= Client.new
  end

  def self.reset
    @config = nil
    @client = nil
  end

  require 'amorail/engine' if defined?(Rails)
end
