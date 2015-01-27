module Amorail
  class AmoContact < Amorail::AmoEntity

    attr_accessor :url, :name, :company_name, :linked_leads_id, :email, :phone, :job_position, :id, :request_id


    def request_attributes
      {
        request: {
          contacts: {
            add: [
              {
                name: self.name,
                linked_leads_id: [self.linked_leads_id],
                company_name: self.company_name,
                custom_fields: [
                  {
                    id: 1460587,
                    values: [{value: self.job_position}]
                  },
                  {
                    id: 1460589,
                    values: [{value: self.phone, enum: 'MOB'}]
                  },
                  {
                    id: 1460591,
                    values: [{value: self.email, enum: 'WORK'}]
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
