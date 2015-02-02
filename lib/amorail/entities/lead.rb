module Amorail
  class AmoLead < Amorail::AmoEntity
    
    attr_accessor :url, :name, :price, :status_id, :tags, :id, :request_id

    def request_attributes
      {
        request: {
          leads: {
            add: [
              {
                name: self.name,
                tags: self.tags,
                price: self.price,
                status_id: self.properties.lead.first_status.id
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
