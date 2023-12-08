# frozen_string_literal: true

module Amorail
  module StoreAdapters
    class MemoryStoreAdapter < AbstractStoreAdapter
      attr_reader :storage

      def initialize(**options)
        raise ArgumentError, 'Memory store doesn\'t support any options' if options.any?
        @storage = Hash.new { |hh, kk| hh[kk] = {} }
      end

      def fetch_access(secret)
        value_if_not_expired(secret)
      end

      def persist_access(secret, token, refresh_token, expiration)
        access_token = { token: token, refresh_token: refresh_token, expiration: expiration }
        storage.store(secret, access_token)
      end

      def update_access(secret, token, refresh_token, expiration)
        update_access_fields(
          secret,
          token: token,
          refresh_token: refresh_token,
          expiration: expiration
        )
      end

      def access_expired?(key)
        storage[key][:expiration] && Time.now.to_i >= storage[key][:expiration]
      end

      private

      def value_if_not_expired(key)
        if !access_expired?(key)
          storage[key]
        else
          { refresh_token: storage[key][:refresh_token] }
        end
      end

      def update_access_fields(key, fields)
        storage[key].merge!(fields)
      end
    end
  end
end
