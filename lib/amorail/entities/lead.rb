module Amorail
  class AmoLead < Amorail::AmoEntity
    
    attr_accessor :url, :name, :price, :status_id, :tags, :id, :request_id

    def initialize(attributes={})
      super
      self.url = "/private/api/v2/json/leads/set"
    end

    def request_attributes
      {
        request: {
          leads: {
            add: [
              {
                name: name,
                tags: tags,
                price: price,
                status_id: properties.lead.first_status.id
              }
            ]
          }
        }
      }
    end

    def reload_model(response)
      self.id = response["leads"]["add"][0]["id"]
      self.request_id = response["leads"]["add"][0]["request_id"]
    end
  end
end
