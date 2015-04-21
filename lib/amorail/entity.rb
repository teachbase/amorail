require 'active_model'

module Amorail
  class AmoEntity
    include ActiveModel::Model
    include ActiveModel::AttributeMethods
    include ActiveModel::Validations

    class InvalidRecord < ::Amorail::Error; end
    class NotPersisted < ::Amorail::Error; end
    class RecordNotFound < ::Amorail::Error; end

    class << self
      attr_reader :amo_name, :amo_response_name, :attributes, :properties

      def amo_names(name, response_name = nil)
        @amo_name = @amo_response_name = name
        @amo_response_name = response_name unless response_name.nil?
      end

      def amo_field(*vars, **hargs)
        @attributes ||= {}
        vars.each { |v| @attributes[v] = :default }
        hargs.each { |k, v| @attributes[k] = v }
        attr_accessor(*@attributes.keys)
      end

      def amo_property(name, options = {})
        @properties ||= {}
        @properties[name] = options
        attr_accessor(name)
      end

      def find(id)
        new.load_record(id)
      end

      def find!(id)
        rec = find(id)
        fail RecordNotFound unless rec
        rec
      end
    end

    amo_names 'entity'

    amo_field :id, :request_id, :responsible_user_id,
              date_create: :timestamp, last_modified: :timestamp

    delegate :client, :properties, to: Amorail

    def initialize(attributes = {})
      super(attributes)
      self.last_modified = Time.now.to_i if last_modified.nil?
    end

    def new_record?
      id.blank?
    end

    def persisted?
      !new_record?
    end

    def load_record(id)
      response = client.safe_request(
        :get,
        remote_url('list'),
        id: id
      )
      handle_response(response, 'load')
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

    def params
      data = {}
      self.class.attributes.each do |k, v|
        data[k] = send("to_#{v}", send(k))
      end

      data[:custom_fields] = custom_fields

      normalize_params(data)
    end

    protected

    def custom_fields
      return unless properties.respond_to?(self.class.amo_name)

      return if self.class.properties.nil?

      props = properties.send(self.class.amo_name)

      custom_fields = []

      self.class.properties.each do |k, v|
        prop_id = props.send(k).id
        prop_val = { value: send(k) }.merge(v)
        custom_fields << { id: prop_id, values: [prop_val] }
      end

      custom_fields
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
          params = normalize_params(val)
          compacted[key] = params unless params.nil?
        end
      end
      compacted.with_indifferent_access
    end

    def to_timestamp(val)
      return if val.nil?

      case val
      when String
        (date = Time.parse(val)) && date.to_i
      when Date
        val.to_time.to_i
      else
        val.to_i
      end
    end

    def to_default(val)
      val
    end

    def reload_model(info)
      merge_params(info)
      merge_custom_fields(info['custom_fields'])
      self
    end

    private

    def merge_params(attrs)
      attrs.each do |k, v|
        action = "#{k}="
        next unless respond_to?(action)
        send(action, v)
      end
      self
    end

    def merge_custom_fields(fields)
      return if fields.nil?
      fields.each do |f|
        fname = "#{f.fetch('code').downcase}="
        fval = f.fetch('values').first.fetch('value')
        send(fname, fval) if respond_to?(fname)
      end
    end

    def attributes_list
      self.class.attributes
    end

    def remote_url(action)
      File.join(Amorail.config.api_path, self.class.amo_name, action)
    end

    # call safe method <safe_request>. safe_request call authorize
    # if current session undefined or expires.
    def push(method)
      response = commit_request(create_params(method))
      handle_response(response, method)
    end

    def commit_request(attrs)
      client.safe_request(
        :post,
        remote_url('set'),
        normalize_params(attrs)
      )
    end

    def handle_response(response, method)
      if response.status == 200
        extract_method = "extract_data_#{method}"
        reload_model(
          send(
            extract_method,
            response.body['response'][self.class.amo_response_name]
          )
        ) if respond_to?(extract_method, true)
        self
      else
        false
      end
    end

    def extract_data_load(response)
      response.first
    end

    def extract_data_add(response)
      response.fetch('add').first
    end
  end
end
