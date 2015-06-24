require 'amorail/entities/leadable'

module Amorail
  # AmoCRM contact entity
  class Contact < Amorail::Entity
    include Leadable
    amo_names 'contacts'

    amo_field :name, :company_name, :linked_company_id

    amo_property :email, enum: 'WORK'
    amo_property :phone, enum: 'MOB'
    amo_property :position
    amo_property :lp_db_id
    amo_property :user_hash

    validates :name, presence: true

    def company
      return if linked_company_id.nil?
      @company ||= Amorail::Company.find(linked_company_id)
    end
  end
end
