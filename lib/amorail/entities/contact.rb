require 'amorail/entities/leadable'

module Amorail
  # AmoCRM contact entity
  class AmoContact < Amorail::AmoEntity
    include Leadable
    amo_names 'contacts'

    amo_field :name, :company_name

    amo_property :email, enum: 'WORK'
    amo_property :phone, enum: 'MOB'
    amo_property :position

    validates :name, presence: true
  end
end
