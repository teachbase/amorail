module Amorail
  # Provides common functionallity for entities
  # that can be attached to another objects.
  module Elementable
    extend ActiveSupport::Concern

    ELEMENT_TYPES = {
      contact: 1,
      lead:    2,
      company: 3,
      task:    4
    }.freeze

    included do
      amo_field :element_id, :element_type

      validates :element_id, :element_type,
                presence: true
    end

    ELEMENT_TYPES.each do |type, value|
      class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{type}=(val)                        # def contact=(val)
          #{type}! if val                        #   contact! if val
        end                                      # end

        def #{type}?                             # def contact?
          self.element_type == #{value}          #   self.element_type == 1
        end                                      # end

        def #{type}!                             # def contact!
          self.element_type = #{value}           #   self.element_type = 1
        end                                      # end
      CODE
    end
  end
end
