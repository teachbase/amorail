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

      delegate :client, to: Amorail

      # copy Amo names
      def inherited(subclass)
        subclass.amo_names amo_name, amo_response_name
      end

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
        @properties ||=
          superclass.respond_to?(:properties) ? superclass.properties.dup : {}
      end

      def remote_url(action)
        File.join(Amorail.config.api_path, amo_name, action)
      end
    end

    amo_field :id, :request_id, :responsible_user_id,
              date_create: :timestamp, last_modified: :timestamp

    delegate :amo_name, :remote_url, :client, to: :class
    delegate :properties, to: Amorail

    def initialize(attributes = {})
      super(attributes)
      self.last_modified = Time.now.to_i if last_modified.nil?
    end

    require 'amorail/entity/params'
    require 'amorail/entity/persistence'
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
        fname = f['code'] || f['name']
        next if fname.nil?

        fname = "#{fname.downcase}="
        fval = f.fetch('values').first.fetch('value')
        send(fname, fval) if respond_to?(fname)
      end
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

    # We can have response with 200 or 204 here.
    # 204 response has no body, so we don't want to parse it.
    def handle_response(response, method)
      return false if response.status == 204

      data = send(
        "extract_data_#{method}",
        response.body['response'][self.class.amo_response_name]
      )
      reload_model(data)
    rescue InvalidRecord
      false
    end
  end
end
