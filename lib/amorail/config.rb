require 'anyway'

module Amorail
  class Config < Anyway::Config

    attr_config :usermail,
                :api_key,
                api_endpoint: 'https://new54c0b12948ffb.amocrm.ru',
                auth_url: '/private/api/auth.php?type=json'
  end
end