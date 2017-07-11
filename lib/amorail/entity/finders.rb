module Amorail # :nodoc: all
  class Entity
    class << self
      # Find AMO entity by id
      def find(id)
        new.load_record(id)
      end

      # Find AMO entity by id
      # and raise RecordNotFound if nothing was found
      def find!(id)
        rec = find(id)
        fail RecordNotFound unless rec
        rec
      end

      def find_all(*ids)
        ids = ids.first if ids.size == 1 && ids.first.is_a?(Array)

        response = client.safe_request(
          :get,
          remote_url('list'),
          id: ids
        )
        load_many(response)
      end

      # Find AMO entities by query
      # Returns array of matching entities.
      def find_by_query(q)
        response = client.safe_request(
          :get,
          remote_url('list'),
          query: q
        )
        load_many(response)
      end

      private

      def load_many(response)
        return [] unless response.status == 200

        (response.body['response'][amo_response_name] || [])
          .map { |info| new.reload_model(info) }
      end
    end

    def load_record(id)
      response = client.safe_request(
        :get,
        remote_url('list'),
        id: id
      )
      handle_response(response, 'load') || nil
    end

    private

    def extract_data_load(response)
      response.first
    end
  end
end
