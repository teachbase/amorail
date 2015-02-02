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
                name: name,
                linked_leads_id: [linked_leads_id],
                type: "contact",
                company_name: company_name,
                custom_fields: [
                  {
                    id: properties.company.address.id,
                    values: [{value: address}]
                  },
                  {
                    id: properties.company.phone.id,
                    values: [{value: phone, enum: "WORK"}]
                  },
                  {
                    id: properties.company.email.id,
                    values: [{value: email, enum: "WORK"}]
                  },
                  {
                    id: properties.company.web.id,
                    values: [{value: website}]
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
