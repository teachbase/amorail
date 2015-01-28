module Amorail
  class Property
    
    def initialize(client)
      @client = client
      @data = load_fields
    end

    def client
      @client
    end

    def data
      @data
    end

    def load_fields
      response = client.safe_request(:get, '/private/api/v2/json/accounts/current')
      response.body["response"]["account"] 
    end

    def contacts
      Contact.parse(data)
    end

    def companies
      Company.parse(data)
    end

    def leads
      Lead.parse(data)
    end

    def tasks
      Task.parse(data)
    end

    class Contact

      def initialize(data)
        @data = data
      end

      def fields
        @data
      end

      def self.parse(data)
        hash = {}
        data.custom_fields.contacts.each do |contact|
          hash[contact.code.downcase] = contact.id
        end
        new hash
      end
    end

    class Company

      def initialize(data)
        @data = data
      end

      def fields
        @data
      end

      def self.parse(data)
        hash = {}
        data.custom_fields.companies.each do |company|
          hash[company.code.downcase] = company.id
        end
        new hash
      end
    end

    class Lead
      def initialize(data)
        @data = data
      end

      def fields
        @data
      end

      def self.parse(data)
        new("first_status" => data.leads_statuses.first.id)
      end
    end

    class Task
      def initialize(data)
        @data = data
      end

      def fields
        @data
      end

      def self.parse(data)
        hash = {}
        data.task_types.each do |tt|
          hash[tt.code.downcase] = tt.id
        end
        new hash
      end
    end

  end
end

class Hash
  def method_missing(method_sym, *arguments, &block)
    if has_key?(method_sym.to_s)
      fetch(method_sym.to_s)
    else
      super
    end
  end
end