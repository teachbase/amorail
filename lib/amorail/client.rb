# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'json'
require 'active_support'

module Amorail
  # Amorail http client
  class Client
    SUCCESS_STATUS_CODES = [200, 204].freeze

    attr_accessor :store
    attr_reader :api_endpoint,
                :access_token,
                :refresh_token,
                :access,
                :client_id,
                :client_secret,
                :code,
                :redirect_uri

    def initialize(api_endpoint: Amorail.config.api_endpoint,
                   client_id: Amorail.config.client_id,
                   client_secret: Amorail.config.client_secret,
                   code: Amorail.config.code,
                   redirect_uri: Amorail.config.redirect_uri)
      @store = Amorail.token_store
      @api_endpoint = api_endpoint
      @client_id = client_id
      @client_secret = client_secret
      @code = code
      @redirect_uri = redirect_uri
      @access = AccessToken.find(@client_secret, store)
      @access_token = @access.token
      @refresh_token = @access.refresh_token

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
      response = post(Amorail.config.auth_url, auth_params)
      create_access_token(response)
      response
    end

    def refresh_token!
      response = post(Amorail.config.auth_url, refresh_params)
      update_access_token(response)
      response
    end

    def auth_params
      {
        client_id: client_id,
        client_secret: client_secret,
        grant_type: 'authorization_code',
        code: @code,
        redirect_uri: redirect_uri
      }
    end

    def refresh_params
      {
        client_id: client_id,
        client_secret: client_secret,
        grant_type: 'refresh_token',
        refresh_token: refresh_token,
        redirect_uri: redirect_uri
      }
    end

    def safe_request(method, url, params = {})
      refresh_token! if access.expired?
      authorize if access_token.blank?
      public_send(method, url, params)
    end

    def get(url, params = {})
      response = connect.get(url, params) do |request|
        request.headers['Authorization'] = "Bearer #{access_token}" if access_token.present?
      end
      handle_response(response)
    end

    def post(url, params = {})
      response = connect.post(url) do |request|
        request.headers['Authorization'] = "Bearer #{access_token}" if access_token.present?
        request.headers['Content-Type'] = 'application/json'
        request.body = params.to_json
      end
      handle_response(response)
    end

    private

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

    def create_access_token(response)
      _access = AccessToken.create(
        client_secret,
        response.body['access_token'],
        response.body['refresh_token'],
        expiration(response.body['expires_in']),
        store
      )
      @access_token = _access.token
      @refresh_token = _access.refresh_token
    end

    def update_access_token(response)
      _access = AccessToken.refresh(
        client_secret,
        response.body['access_token'],
        response.body['refresh_token'],
        expiration(response.body['expires_in']),
        store
      )
      @access_token = _access.token
      @refresh_token = _access.refresh_token
    end

    def expiration(expires_in)
      Time.now.to_i + expires_in.to_i
    end
  end
end
