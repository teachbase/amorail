module Amorail
  # Return hash key as method call
  module MethodMissing
    def method_missing(method_sym, *arguments, &block)
      if data.key?(method_sym.to_s)
        data.fetch(method_sym.to_s)
      else
        super
      end
    end

    def respond_to_missing?(method_sym, *args)
      args.size.zero? && data.key?(method_sym.to_s)
    end
  end

  class Property # :nodoc: all
    class PropertyItem
      include MethodMissing

      class << self
        attr_accessor :source_name

        def parse(data)
          hash = {}
          data['custom_fields'].fetch(source_name, []).each do |contact|
            identifier = contact['code'].presence || contact['name'].presence
            next if identifier.nil?

            hash[identifier.downcase] = PropertyItem.new(contact)
          end
          new hash
        end
      end

      attr_reader :data

      def initialize(data)
        @data = data
      end

      def [](key)
        @data[key]
      end
    end

    class StatusItem
      attr_reader :statuses

      def initialize(data)
        @statuses = data
      end
    end

    attr_reader :client, :data, :contacts,
                :company, :leads, :tasks

    def initialize(client)
      @client = client
      reload
    end

    def reload
      @data = load_fields
      parse_all_data
    end

    def load_fields
      response = client.safe_request(
        :get,
        '/private/api/v2/json/accounts/current'
      )
      response.body["response"]["account"]
    end

    def inspect
      @data
    end

    private

    def parse_all_data
      @contacts = Contact.parse(data)
      @company = Company.parse(data)
      @leads = Lead.parse(data)
      @tasks = Task.parse(data)
    end

    class Contact < PropertyItem
      self.source_name = 'contacts'
    end

    class Company < PropertyItem
      self.source_name = 'companies'
    end

    class Lead < PropertyItem
      self.source_name = 'leads'

      attr_accessor :statuses

      class << self
        def parse(data)
          obj = super
          hash = {}
          data.fetch('leads_statuses', []).each do |prop|
            hash[prop['name']] = PropertyItem.new(prop)
          end
          obj.statuses = hash
          obj
        end
      end
    end

    class Task < PropertyItem
      def self.parse(data)
        hash = {}
        data.fetch('task_types', []).each do |tt|
          prop_item = PropertyItem.new(tt)
          identifier = tt['code'].presence || tt['name'].presence
          next if identifier.nil?

          hash[identifier.downcase] = prop_item
          hash[identifier] = prop_item
        end
        new hash
      end
    end
  end
end
