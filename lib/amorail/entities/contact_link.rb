module Amorail
  # AmoCRM contact-link join model
  class ContactLink < Amorail::Entity
    amo_names "contacts", "links"

    amo_field :contact_id, :lead_id

    class << self
      # Find links by contacts ids
      def find_by_contacts(*ids)
        ids = ids.first if ids.size == 1 && ids.first.is_a?(Array)
        response = client.safe_request(
          :get,
          remote_url('links'),
          contacts_link: ids
        )
        load_many(response)
      end

      # Find links by leads ids
      def find_by_leads(*ids)
        ids = ids.first if ids.size == 1 && ids.first.is_a?(Array)
        response = client.safe_request(
          :get,
          remote_url('links'),
          deals_link: ids
        )
        load_many(response)
      end
    end
  end
end
