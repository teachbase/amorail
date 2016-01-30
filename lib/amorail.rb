require 'amorail/version'
require 'amorail/config'
require 'amorail/client'
require 'amorail/exceptions'
require 'amorail/entity'
require 'amorail/property'

Gem.find_files('amorail/entities/*.rb').each { |path| require path }

# AmoCRM API integration.
# https://www.amocrm.com/
module Amorail
  def self.config
    @config ||= Config.new
  end

  def self.properties
    client.properties
  end

  def self.configure
    yield(config) if block_given?
  end

  def self.client
    ClientRegistry.client || (@client ||= Client.new)
  end

  def self.reset
    @config = nil
    @client = nil
  end

  def self.with_client(client)
    client = Client.new(client) unless client.is_a?(Client)
    ClientRegistry.client = client
    yield
    ClientRegistry.client = nil
  end

  class ClientRegistry # :nodoc:
    extend ActiveSupport::PerThreadRegistry

    attr_accessor :client
  end

  require 'amorail/engine' if defined?(Rails)
end
