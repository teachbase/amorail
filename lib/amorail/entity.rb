require 'active_model'

module Amorail
  # Core class for all Amo entities (company, contact, etc)
  class Entity
    include ActiveModel::Model
    include ActiveModel::AttributeMethods
    include ActiveModel::Validations

    class RecordNotFound < ::Amorail::Error; end

    class << self
      attr_reader :amo_name, :amo_response_name

      def amo_names(name, response_name = nil)
        @amo_name = @amo_response_name = name
        @amo_response_name = response_name unless response_name.nil?
      end

      def amo_field(*vars, **hargs)
        vars.each { |v| attributes[v] = :default }
        hargs.each { |k, v| attributes[k] = v }
        attr_accessor(*(vars + hargs.keys))
      end

      def amo_property(name, options = {})
        properties[name] = options
        attr_accessor(name)
      end

      def attributes
        @attributes ||=
          superclass.respond_to?(:attributes) ? superclass.attributes.dup : {}
      end

      def properties
        @properties ||= {}
      end
    end

    amo_names 'entity'

    amo_field :id, :request_id, :responsible_user_id,
              date_create: :timestamp, last_modified: :timestamp

    delegate :client, :properties, to: Amorail
    delegate :amo_name, to: :class

    def initialize(attributes = {})
      super(attributes)
      self.last_modified = Time.now.to_i if last_modified.nil?
    end

    require 'amorail/entity/params'
    require 'amorail/entity/persistance'
    require 'amorail/entity/finders'

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
        fname = "#{f.fetch('code', f.fetch('name')).downcase}="
        fval = f.fetch('values').first.fetch('value')
        send(fname, fval) if respond_to?(fname)
      end
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
      return false unless response.status == 200
      extract_method = "extract_data_#{method}"
      reload_model(
        send(extract_method,
             response.body['response'][self.class.amo_response_name]
            )
      ) if respond_to?(extract_method, true)
      self
    end
  end
end
