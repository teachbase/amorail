require "amorail/version"
require "amorail/config"
require "amorail/client"

module Amorail
  
  def self.config
    @config ||= Config.new
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
end
