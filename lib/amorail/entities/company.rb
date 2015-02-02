module Amorail
  class AmoCompany < Amorail::AmoEntity
    
    attr_accessor :url, :name, :linked_leads_id, :email, :phone, :address, 
                  :website, :id, :request_id, :company_name

    def request_attributes
      {
        request: {
          contacts: {
            add: [
              {
                name: self.name,
                linked_leads_id: [self.linked_leads_id],
                type: 'contact',
                company_name: self.company_name,
                custom_fields: [
                  {
                    id: self.properties.company.address.id,
                    values: [{value: self.address}]
                  },
                  {
                    id: self.properties.company.phone.id,
                    values: [{value: self.phone, enum: 'WORK'}]
                  },
                  {
                    id: self.properties.company.email.id,
                    values: [{value: self.email, enum: 'WORK'}]
                  },
                  {
                    id: self.properties.company.web.id,
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
