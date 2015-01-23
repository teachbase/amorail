require 'faraday'
require 'json'

module Amorail
  class Client

    def initialize
      @host = Amorail.config.api_endpoint
      @connect = Faraday.new(url: @host) do |faraday|
        faraday.response :logger                  
        faraday.adapter  Faraday.default_adapter
      end
    end

    def connect
      @connect || self.class.new
    end

    def authorize
      response = post(Amorail.config.auth_url, {'USER_LOGIN' => Amorail.config.usermail, 'USER_HASH' => Amorail.config.api_key})
    end

    def get(url, params={})
    end

    def post(url, params={})
      connect.post do |request|
        request.url = url
        request.headers['Content-Type'] = 'application/json'
        request.body = params.to_json
      end
    end
  end
end