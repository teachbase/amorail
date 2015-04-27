module Amorail # :nodoc: all
  class Entity
    class << self
      def find(id)
        new.load_record(id)
      end

      def find!(id)
        rec = find(id)
        fail RecordNotFound unless rec
        rec
      end
    end

    def load_record(id)
      response = client.safe_request(
        :get,
        remote_url('list'),
        id: id
      )
      handle_response(response, 'load')
    end

    private

    def extract_data_load(response)
      response.first
    end
  end
end
