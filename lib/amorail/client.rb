require 'faraday'
require 'faraday_middleware'
require 'json'
require 'active_support'

module Amorail
  class Client

    attr_accessor :cookies

    def initialize
      @host = Amorail.config.api_endpoint
      @connect = Faraday.new(url: @host) do |faraday|           
        faraday.adapter  Faraday.default_adapter
        faraday.response :json, :content_type => /\bjson$/
        faraday.use :instrumentation
      end
    end

    def connect
      @connect || self.class.new
    end

    def authorize
      response = post(Amorail.config.auth_url, {'USER_LOGIN' => Amorail.config.usermail, 'USER_HASH' => Amorail.config.api_key})
      cookie_handler(response)
      response
    end

    def load_custom_fields
      response = get('/private/api/v2/json/accounts/current')
      contacts = {}
      companies = {}
      fields = response.body["response"]["account"]["custom_fields"]
      statuses = response.body["response"]["account"]["leads_statuses"]
      fields["contacts"].each do |field|
        contacts[field["code"]] = field["id"] 
      end
      fields["companies"].each do |field|
        companies[field["code"]] = field["id"] 
      end
      [contacts, companies, statuses]
    end

    def get(url, params={})
      response = connect.get(url) do |request|
        request.headers['Cookie'] = self.cookies if self.cookies.present?
        request.headers['Content-Type'] = 'application/json'
        request.body = params.to_json
      end
      hadle_response(response)
      response
    end

    def post(url, params={})
      response = connect.post(url) do |request|
        request.headers['Cookie'] = self.cookies if self.cookies.present?
        request.headers['Content-Type'] = 'application/json'
        request.body = params.to_json
      end

      hadle_response(response)
      response
    end

    def cookie_handler(response)
      self.cookies = response.headers['set-cookie'].split('; ')[0]
    end

    def hadle_response(response)
      case response.status
        when 301
          raise AmoMovedPermanentlyError
        when 400
          raise AmoBadRequestError
        when 401 
          raise AmoUnauthorizedError
        when 403
          raise AmoForbiddenError
        when 404
          raise AmoNotFoudError
        when 500
          raise AmoInternalError
        when 502
          raise AmoBadGatewayError
        when 503
          raise AmoServiceUnaviableError
      end
    end
  end
end