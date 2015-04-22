module Amorail
  # AmoCRM lead entity
  class AmoLead < Amorail::AmoEntity
    amo_names "leads"

    amo_field :name, :price, :status_id, :tags

    validates :name, :status_id, presence: true
  end
end
