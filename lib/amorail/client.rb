require 'faraday'
require 'faraday_middleware'
require 'json'
require 'active_support'

module Amorail
  # Amorail http client
  class Client
    attr_accessor :cookies

    def initialize
      @host = Amorail.config.api_endpoint
      @connect = Faraday.new(url: @host) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.response :json, content_type: /\bjson$/
        faraday.use :instrumentation
      end
    end

    def connect
      @connect || self.class.new
    end

    def authorize
      response = post(
        Amorail.config.auth_url,
        'USER_LOGIN' => Amorail.config.usermail,
        'USER_HASH' => Amorail.config.api_key
      )
      cookie_handler(response)
      response
    end

    def safe_request(method, url, params = {})
      send(method, url, params)
    rescue ::Amorail::AmoUnauthorizedError
      authorize
      send(method, url, params)
    end

    def get(url, params = {})
      response = connect.get(url, params) do |request|
        request.headers['Cookie'] = cookies if cookies.present?
      end
      handle_response(response)
    end

    def post(url, params = {})
      response = connect.post(url) do |request|
        request.headers['Cookie'] = cookies if cookies.present?
        request.headers['Content-Type'] = 'application/json'
        request.body = params.to_json
      end
      handle_response(response)
    end

    def cookie_handler(response)
      self.cookies = response.headers['set-cookie'].split('; ')[0]
    end

    def handle_response(response) # rubocop:disable all
      return response if response.status == 200 || response.status == 204

      case response.status
      when 301
        fail ::Amorail::AmoMovedPermanentlyError
      when 400
        fail ::Amorail::AmoBadRequestError
      when 401
        fail ::Amorail::AmoUnauthorizedError
      when 403
        fail ::Amorail::AmoForbiddenError
      when 404
        fail ::Amorail::AmoNotFoudError
      when 500
        fail ::Amorail::AmoInternalError
      when 502
        fail ::Amorail::AmoBadGatewayError
      when 503
        fail ::Amorail::AmoServiceUnaviableError
      else
        fail ::Amorail::AmoUnknownError(response.body)
      end
    end
  end
end
