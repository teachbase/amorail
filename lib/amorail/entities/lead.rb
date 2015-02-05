module Amorail
  class AmoLead < Amorail::AmoEntity
    set_amo_name "leads"
    attr_accessor :name, :price, :status_id, :tags

    validates :name, :status_id, presence: true

    def create_params
      {
        request: {
          leads: {
            add: [
              {
                name: name,
                date_create: to_timestamp(date_create),
                last_modified: to_timestamp(last_modified),
                request_id: request_id,
                responsible_user_id: responsible_user_id,
                tags: tags,
                price: price,
                status_id: status_id
              }
            ]
          }
        }
      }
    end
  end
end
