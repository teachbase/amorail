module Amorail
  module Elementable
    extend ActiveSupport::Concern

    ELEMENT_TYPES = [
      { name: 'contact', val: 1 },
      { name: 'lead',    val: 2 },
      { name: 'company', val: 3 }
    ].freeze

    included do
      amo_field :element_id, :element_type

      validates :element_id, :element_type,
                presence: true

      validates :element_type, inclusion: 1..3
    end

    ELEMENT_TYPES.each do |type|
      class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{type[:name]}=(val)
          #{type[:name]}! if val
        end

        def #{type[:name]}?
          self.element_type == #{type[:val]}
        end

        def #{type[:name]}!
          self.element_type = #{type[:val]}
        end
      CODE
    end
  end
end
