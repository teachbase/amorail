# frozen_string_literal: true

module Amorail
  class AccessToken
    attr_reader :token, :secret, :expiration, :refresh_token, :store

    def initialize(secret, token, refresh_token, expiration, store)
      @secret        = secret
      @token         = token
      @refresh_token = refresh_token
      @expiration    = expiration
      @store         = store
    end

    def expired?
      store.access_expired?(secret)
    end

    class << self
      def create(secret, token, refresh_token, expiration, store)
        new(secret, token, refresh_token, expiration, store).tap do |access_token|
          store.persist_access(access_token.secret, access_token.token, access_token.refresh_token, access_token.expiration)
        end
      end

      def find(secret, store)
        token_attrs = store.fetch_access(secret)
        build_with_token_attrs(store, secret, token_attrs)
      end

      def refresh(secret, token, refresh_token, expiration, store)
        new(secret, token, refresh_token, expiration, store).tap do |access_token|
          store.update_access(access_token.secret, access_token.token, access_token.refresh_token, access_token.expiration)
        end
      end

      private

      def build_with_token_attrs(store, secret, token_attrs)
        new(secret, token_attrs[:token], token_attrs[:refresh_token], token_attrs[:expiration], store)
      end
    end
  end
end
