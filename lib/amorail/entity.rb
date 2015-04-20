require 'active_model'

module Amorail
  class AmoEntity
    include ActiveModel::Model
    include ActiveModel::AttributeMethods
    include ActiveModel::Validations

    class InvalidRecord < ::Amorail::Error; end
    class NotPersisted < ::Amorail::Error; end

    class << self
      attr_reader :amo_name, :amo_response_name
      def set_amo_name(name)
        @amo_name = @amo_response_name = name
      end

      def set_amo_response_name(name)
        @amo_response_name = name
      end
    end

    attr_accessor :id, :date_create, :last_modified, :persisted,
                  :request_id, :responsible_user_id

    def initialize(attributes = {})
      super
      @client = Amorail.client
      @properties = Amorail.properties
    end

    def self.attr_accessor(*vars)
      @attributes ||= []
      @attributes.concat vars
      super(*vars)
    end

    def self.find(id)
      new(id: id)
    end

    class << self
      attr_reader :attributes
    end

    def attributes
      attrs = {}
      attributes_list.each { |a| attrs[a] = send(a) }
      attrs
    end

    def attributes_list
      self.class.attributes
    end

    attr_reader :client

    attr_reader :properties

    def new_record?
      id.blank?
    end

    def persisted?
      persisted.present? && !new_record?
    end

    def params
      {}
    end

    def create_params(method)
      {
        request: {
          self.class.amo_response_name => {
            method => [
              params
            ]
          }
        }
      }
    end

    def save
      return false unless valid?
      new_record? ? push('add') : push('update')
    end

    def save!
      if save
        true
      else
        fail InvalidRecord
      end
    end

    def update(attrs = {})
      return false if new_record?
      merge_params(attrs)
      push('update')
    end

    def update!(attrs = {})
      if update(attrs)
        true
      else
        fail NotPersisted
      end
    end

    # after update merge updated params
    def merge_params(attrs)
      return nil unless attrs.present?
      attrs.each do |k, v|
        action = "#{k}="
        next unless respond_to?(action)
        send(action, v)
      end
      self
    end

    def normalize_custom_fields(val)
      val.reject do |field|
        field[:values].all? { |item| !item[:value] }
      end
    end

    # this method removes nil values and empty arrays from params hash (deep)
    def normalize_params(data)
      return data unless data.is_a?(Hash)

      compacted = {}
      data.each do |key, val|
        case val
        when Numeric, String
          compacted[key] = val
        when Array
          val.compact!
          # handle custom keys
          val = normalize_custom_fields(val) if key == :custom_fields
          unless val.empty?
            compacted[key] = val.map { |el| normalize_params(el) }
          end
        else
          _data = normalize_params(val)
          compacted[key] = _data unless _data.nil?
        end
      end
      compacted.with_indifferent_access
    end

    protected

    def to_timestamp(val)
      return if val.nil?

      case val
      when String
        (_date = Date.parse(val)) && _date.to_i
      when Time
        val.to_i
      when Date
        val.to_time.to_i
      when Numeric
        val.to_i
      end
    end

    private

    # call safe method <safe_request>. safe_request call authorize
    # if current session undefined or expires.
    def push(method)
      return false if method.blank?
      response = commit_request(create_params(method))
      handle_response(response)
    end

    def commit_request(attrs)
      response = client.safe_request(
        :post,
        create_url,
        normalize_params(attrs)
      )
    end

    def handle_response(response)
      if response.status == 200
        reload_model(response.body['response'])
        true
      else
        false
      end
    end

    # override this method for Amo<Any> class
    def reload_model(response)
      if new_record?
        self.id = response[self.class.amo_response_name]['add'][0]['id']
        self.request_id = response[self.class.amo_response_name]['add'][0]['request_id']
      else
        self.persisted = true
      end
    end

    def current_time
      Time.zone.present? ? Time.zone.now : Time.now
    end

    def create_url
      File.join("#{Amorail.config.api_path}", self.class.amo_name, 'set')
    end
  end
end
