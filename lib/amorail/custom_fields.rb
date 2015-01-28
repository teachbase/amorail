require 'pry-byebug'

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

      def initialize(data)
        @data = data
      end

      def data
        @data
      end
    end
    
    def initialize(client)
      @client = client
      @data = load_fields
      parse_all_data
    end

    def client
      @client
    end

    def data
      @data
    end

    def parse_all_data
      @contact = Contact.parse(data)
      @company = Company.parse(data)
      @lead = Lead.parse(data)
      @task = Task.parse(data)
    end

    def load_fields
      response = client.safe_request(:get, '/private/api/v2/json/accounts/current')
      if response.body.is_a?(Hash)
        response.body["response"]["account"]
      elsif response.body.is_a?(String)
        JSON.parse(response.body)["response"]["account"]
      end
    end

    def contact
      @contact ||= Contact.parse(data)
    end

    def company
      @company ||= Company.parse(data)
    end

    def lead
      @lead ||= Lead.parse(data)
    end

    def task
      @task ||= Task.parse(data)
    end

    class Contact
      include MethodMissing

      def initialize(data)
        @data = data
      end

      def data
        @data
      end

      def self.parse(data)
        hash = {}
        data['custom_fields']['contacts'].each do |contact|
          hash[contact['code'].downcase] = PropertyItem.new(contact)
        end
        new hash
      end
    end

    class Company
      include MethodMissing

      def initialize(data)
        @data = data
      end

      def data
        @data
      end

      def self.parse(data)
        hash = {}
        data['custom_fields']['companies'].each do |company|
          hash[company['code'].downcase] = PropertyItem.new(company)
        end
        new hash
      end
    end

    class Lead
      include MethodMissing

      def initialize(data)
        @data = data
      end

      def data
        @data
      end

      def self.parse(data)
        hash = {"first_status" => PropertyItem.new(data['leads_statuses'].first)}
        new hash
      end
    end

    class Task
      include MethodMissing

      def initialize(data)
        @data = data
      end

      def data
        @data
      end

      def self.parse(data)
        hash = {}
        data['task_types'].each do |tt|
          hash[tt['code'].downcase] = PropertyItem.new(tt)
        end
        new hash
      end
    end
  end
end