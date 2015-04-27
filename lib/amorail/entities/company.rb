require 'amorail/entities/leadable'

module Amorail
  # AmoCRM company entity
  class Company < Amorail::Entity
    include Leadable
    amo_names 'company', 'contacts'

    amo_field :name
    amo_property :email, enum: 'WORK'
    amo_property :phone, enum: 'WORK'
    amo_property :address
    amo_property :web

    validates :name, presence: true

    def params
      data = super
      data[:type] = 'contact'
      data
    end
  end
end
