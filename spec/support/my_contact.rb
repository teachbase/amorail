# frozen_string_literal: true

class MyContact < Amorail::Contact # :nodoc:
  amo_property :teachbase_id
  amo_property :phone, enum: 'MOB', multiple: true
end
