module Amorail
  class AmoCompany < Amorail::AmoEntity
    attr_accessor :url, :name, :linked_leads_id, :email, :phone, :address, :website, :id, :request_id

    def request_attributes
      {
        request: {
          contacts: {
            add: [
              {
                name: self.name,
                linked_leads_id: self.linked_leads_id,
                type: 'contact',
                custom_fields: [
                  {
                    id: 1460597,
                    values: [{value: self.address}]
                  },
                  {
                    id: 1460589,
                    values: [{value: self.phone, enum: 'WORK'}]
                  },
                  {
                    id: 1460591,
                    values: [{value: self.email, enum: 'WORK'}]
                  },
                  {
                    id: 1460593,
                    values: [{value: self.website}]
                  }
                ]
              }
            ]
          }
        }
      }
    end

    def reload_model(response)
      self.id = response["contacts"]["add"][0]["id"]
      self.request_id = response["contacts"]["add"][0]["request_id"]
    end
  end
end
