module Amorail
  # Lead associations
  module Leadable
    extend ActiveSupport::Concern

    included do
      amo_field :linked_leads_id
    end

    # Set initial value for linked_leads_id to []
    def initialize(*args)
      super
      self.linked_leads_id ||= []
    end

    # Clear leads cache on reload
    def reload
      @leads = nil
      super
    end

    # Return all linked leads
    def leads
      return [] if linked_leads_id.empty?

      @leads ||= Amorail::Lead.find_all(linked_leads_id)
    end
  end
end
