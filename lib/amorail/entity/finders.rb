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

      # General method to load many records by proving some filters
      def where(options)
        response = client.safe_request(
          :get,
          remote_url('list'),
          options
        )
        load_many(response)
      end

      def find_all(*ids)
        ids = ids.first if ids.size == 1 && ids.first.is_a?(Array)

        where(id: ids)
      end

      # Find AMO entities by query
      # Returns array of matching entities.
      def find_by_query(query)
        where(query: query)
      end

      private

      # We can have response with 200 or 204 here.
      # 204 response has no body, so we don't want to parse it.
      def load_many(response)
        return [] if response.status == 204

        response.body['response'].fetch(amo_response_name, [])
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
