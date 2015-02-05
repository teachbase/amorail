module Amorail

  module MethodMissing
    def method_missing(method_sym, *arguments, &block)
      if data.has_key?(method_sym.to_s)
        data.fetch(method_sym.to_s)
      else
        super
      end
    end
  end

  class Property

    class PropertyItem
      include MethodMissing

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
    
    attr_reader :client, :data, :contact, 
                :company, :lead, :task

    def initialize(client)
      @client = client
      reload
    end

    def reload
      @data = load_fields
      parse_all_data
    end
    
    def load_fields
      response = client.safe_request(:get, '/private/api/v2/json/accounts/current')
      if response.body.is_a?(Hash)
        response.body["response"]["account"]
      elsif response.body.is_a?(String)
        JSON.parse(response.body)["response"]["account"]
      end
    end

    def inspect
      @data
    end

    private

    def parse_all_data
      @contact = Contact.parse(data)
      @company = Company.parse(data)
      @lead = Lead.parse(data)
      @task = Task.parse(data)
    end

    class Contact < PropertyItem
      def self.parse(data)
        hash = {}
        data['custom_fields']['contacts'].each do |contact|
          hash[contact['code'].downcase] = PropertyItem.new(contact)
        end
        new hash
      end
    end

    class Company < PropertyItem
      def self.parse(data)
        hash = {}
        data['custom_fields']['companies'].each do |company|
          hash[company['code'].downcase] = PropertyItem.new(company)
        end
        new hash
      end
    end

    class Lead < StatusItem
      def self.parse(data)
        hash = {}
        data['leads_statuses'].each do |prop|
          hash[prop['name']] = PropertyItem.new(prop)
        end
        new hash
      end
    end

    class Task < PropertyItem
      def self.parse(data)
        hash = {}
        data['task_types'].each do |tt|
          prop_item = PropertyItem.new(tt)
          hash[tt['code'].downcase] = prop_item
          hash[tt['code']] = prop_item
        end
        new hash
      end
    end
  end
end