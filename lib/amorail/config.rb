# frozen_string_literal: true

require 'anyway'

module Amorail
  # Amorail config contains:
  # - api_endpoint ("http://you_company.amocrm.com")
  # - api_path (default: "/private/api/v2/json/")
  # - auth_url (default: "/oauth2/access_token")
  class Config < Anyway::Config
    attr_config :api_endpoint,
                :client_id,
                :client_secret,
                :code,
                :redirect_uri,
                :redis_url,
                api_path: '/private/api/v2/json/',
                auth_url: '/oauth2/access_token',
                redis_host: '127.0.0.1',
                redis_port: '6379',
                redis_db_name: '0'
  end
end
