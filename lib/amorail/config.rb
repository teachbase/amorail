require 'anyway'

module Amorail
  # Amorail config contains:
  # - usermail ("user@gmail.com")
  # - api_key ("13601bbac84727df")
  # - api_endpoint ("http://you_company.amocrm.com")
  # - api_path (default: "/private/api/v2/json/")
  # - auth_url (default: "/private/api/auth.php?type=json")
  class Config < Anyway::Config
    attr_config :usermail,
                :api_key,
                :api_endpoint,
                api_path: "/private/api/v2/json/",
                auth_url: "/private/api/auth.php?type=json"
  end
end
