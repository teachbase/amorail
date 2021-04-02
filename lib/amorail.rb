# frozen_string_literal: true

require 'amorail/version'
require 'amorail/config'
require 'amorail/client'
require 'amorail/exceptions'
require 'amorail/entity'
require 'amorail/property'
require 'amorail/access_token'
require 'amorail/store_adapters'

Gem.find_files('amorail/entities/*.rb').each { |path| require path }

# AmoCRM API integration.
# https://www.amocrm.com/
module Amorail
  extend self

  def config
    @config ||= Config.new
  end

  def properties
    client.properties
  end

  def configure
    yield(config) if block_given?
  end

  def client
    ClientRegistry.client || (@client ||= Client.new)
  end

  def reset
    @config = nil
    @client = nil
  end

  def with_client(client)
    client = Client.new(client) unless client.is_a?(Client)
    ClientRegistry.client = client
    yield
  ensure
    ClientRegistry.client = nil
  end

  def token_store=(args)
    adapter, options = Array(args)
    @token_store = StoreAdapters.build_by_name(adapter, options)
  rescue NameError => e
    raise e.class, "Token store adapter for :#{adapter} haven't been found", e.backtrace
  end

  def token_store
    unless instance_variable_defined?(:@token_store)
      self.token_store = :memory
    end

    @token_store
  end

  class ClientRegistry # :nodoc:
    extend ActiveSupport::PerThreadRegistry

    attr_accessor :client
  end

  require 'amorail/railtie' if defined?(Rails)
end
