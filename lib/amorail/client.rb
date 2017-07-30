require 'faraday'
require 'faraday_middleware'
require 'json'
require 'active_support'

module Amorail
  # Amorail http client
  class Client
    SUCCESS_STATUS_CODES = [200, 204].freeze

    attr_reader :usermail, :api_key, :api_endpoint

    def initialize(api_endpoint: Amorail.config.api_endpoint,
                   api_key: Amorail.config.api_key,
                   usermail: Amorail.config.usermail)
      @api_endpoint = api_endpoint
      @api_key = api_key
      @usermail = usermail
      @connect = Faraday.new(url: api_endpoint) do |faraday|
        faraday.response :json, content_type: /\bjson$/
        faraday.use :instrumentation
        faraday.adapter Faraday.default_adapter
      end
    end

    def properties
      @properties ||= Property.new(self)
    end

    def connect
      @connect || self.class.new
    end

    def authorize
      self.cookies = nil
      response = post(
        Amorail.config.auth_url,
        'USER_LOGIN' => usermail,
        'USER_HASH' => api_key
      )
      cookie_handler(response)
      response
    end

    def safe_request(method, url, params = {})
      public_send(method, url, params)
    rescue ::Amorail::AmoUnauthorizedError
      authorize
      public_send(method, url, params)
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

    private

    attr_accessor :cookies

    def cookie_handler(response)
      self.cookies = response.headers['set-cookie'].split('; ')[0]
    end

    def handle_response(response) # rubocop:disable all
      return response if SUCCESS_STATUS_CODES.include?(response.status)

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
        fail ::Amorail::AmoNotFoundError
      when 500
        fail ::Amorail::AmoInternalError
      when 502
        fail ::Amorail::AmoBadGatewayError
      when 503
        fail ::Amorail::AmoServiceUnaviableError
      else
        fail ::Amorail::AmoUnknownError, response.body
      end
    end
  end
end
