module Amorail
  class AmoContact < Amorail::AmoEntity

    attr_accessor :url, :name, :company_name, :linked_leads_id, :email, :phone, :job_position, :id, :request_id


    def request_attributes
      {
        request: {
          contacts: {
            add: [
              {
                name: name,
                linked_leads_id: [linked_leads_id],
                company_name: company_name,
                custom_fields: [
                  {
                    id: properties.contact.position.id,
                    values: [{value: job_position}]
                  },
                  {
                    id: properties.contact.phone.id,
                    values: [{value: phone, enum: "MOB"}]
                  },
                  {
                    id: properties.contact.email.id,
                    values: [{value: email, enum: "WORK"}]
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
