module Amorail
  # AmoCRM task entity
  class Note < Amorail::Entity
    amo_names "notes"

    amo_field :element_id, :element_type, :text,
              :note_type

    validates :text, :element_id,
              :element_type, :note_type,
              presence: true

    validates :element_type, inclusion: 1..2

    [{ name: "contact", val: 1 }, { name: "lead", val: 2 }].each do |prop|
      class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{prop[:name]}=(val)
          #{prop[:name]}! if val
        end
        def #{prop[:name]}?
          self.element_type == #{prop[:val]}
        end
        def #{prop[:name]}!
          self.element_type = #{prop[:val]}
        end
      CODE
    end
  end
end