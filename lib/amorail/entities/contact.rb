module Amorail
  class AmoContact < Amorail::AmoEntity
    include Leadable
    amo_names 'contacts'

    amo_field :name, :company_name

    amo_property :email, enum: 'MOB'
    amo_property :phone, enum: 'WORK'
    amo_property :position

    validates :name, presence: true
  end
end
