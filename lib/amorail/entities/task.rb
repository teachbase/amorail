module Amorail
  # AmoCRM task entity
  class AmoTask < Amorail::AmoEntity
    amo_names "tasks"

    amo_field :element_id, :element_type, :text,
              :task_type, complete_till: :timestamp

    validates :text, :element_id,
              :element_type, :complete_till,
              :task_type,
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
