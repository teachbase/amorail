# frozen_string_literal: true

require 'amorail/entities/elementable'

module Amorail
  # AmoCRM task entity
  class Task < Amorail::Entity
    include Elementable

    amo_names 'tasks'

    amo_field :task_type, :text, complete_till: :timestamp

    validates :task_type, :text, :complete_till,
              presence: true

    validates :element_type, inclusion:
              ELEMENT_TYPES.reject { |type, _| type == :task }.values
  end
end
