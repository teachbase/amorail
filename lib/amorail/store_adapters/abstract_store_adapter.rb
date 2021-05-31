# frozen_string_literal: true

module Amorail
  module StoreAdapters
    class AbstractStoreAdapter
      def fetch_access(_secret)
        raise NotImplementedError
      end

      def persist_access(_secret, _token, _refresh_token, _expiration)
        raise NotImplementedError
      end

      def update_refresh(_secret, _token, _refresh_token, _expiration)
        raise NotImplementedError
      end

      def access_expired?(_key)
        raise NotImplementedError
      end
    end
  end
end
