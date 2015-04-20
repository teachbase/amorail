module Amorail
  class AmoCompany < Amorail::AmoEntity
    set_amo_name 'company'
    set_amo_response_name 'contacts'

    attr_accessor :name, :linked_leads_id,
                  :email, :phone, :address, :website

    validates :name, presence: true

    def params
      {
        id: id,
        name: name,
        type: 'contact',
        date_create: to_timestamp(date_create),
        last_modified: to_timestamp(last_modified) || Time.now.to_i,
        request_id: request_id,
        responsible_user_id: responsible_user_id,
        linked_leads_id: [linked_leads_id],
        custom_fields: [
          {
            id: properties.company.address.id,
            values: [{ value: address }]
          },
          {
            id: properties.company.phone.id,
            values: [{ value: phone, enum: 'WORK' }]
          },
          {
            id: properties.company.email.id,
            values: [{ value: email, enum: 'WORK' }]
          },
          {
            id: properties.company.web.id,
            values: [{ value: website }]
          }
        ]
      }
    end
  end
end
