module Amorail
  # AmoCRM lead entity
  class Lead < Amorail::Entity
    amo_names "leads"

    amo_field :name, :price, :status_id, :tags

    validates :name, :status_id, presence: true

    def reload
      @contacts = nil
      super
    end

    # Return list of associated contacts
    def contacts
      fail NotPersisted if id.nil?
      @contacts ||=
        begin
          links = Amorail::ContactLink.find_by_leads(id)
          links.empty? ? [] : Amorail::Contact.find_all(links.map(&:contact_id))
        end
    end
  end
end
