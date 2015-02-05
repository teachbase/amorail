module Amorail
  class AmoContact < Amorail::AmoEntity
    set_amo_name "contacts"

    attr_accessor :name, :company_name, :linked_leads_id,
                  :email, :phone, :job_position

    validates :name, presence: true

    def create_params
      {
        request: {
          contacts: {
            add: [
              {
                name: name,
                date_create: to_timestamp(date_create),
                last_modified: to_timestamp(last_modified),
                request_id: request_id,
                responsible_user_id: responsible_user_id,
                company_name: company_name,
                linked_leads_id: [linked_leads_id],
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
