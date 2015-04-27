module Amorail
  # Lead associations
  module Leadable
    def linked_leads_id
      @linked_leads_id ||= []
    end

    def params
      data = super
      data[:linked_leads_id] = linked_leads_id unless linked_leads_id.empty?
      data
    end
  end
end
