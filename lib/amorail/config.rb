require 'anyway'

module Amorail
  class Config < Anyway::Config

    attr_config :usermail,
                :api_key,
                :api_endpoint,
                api_path: '/private/api/v2/json/',
                auth_url: '/private/api/auth.php?type=json'
  end
end