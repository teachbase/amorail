# frozen_string_literal: true

module Amorail
  module StoreAdapters
    class RedisStoreAdapter < AbstractStoreAdapter
      attr_reader :storage

      def initialize(**options)
        begin
          require 'redis'
          @storage = configure_redis_client(**options)
        rescue LoadError => e
          msg = 'Could not load the \'redis\' gem, please add it to your gemfile or ' \
                'configure a different adapter (e.g. Amorail.store_adapter = :memory)'
          raise e.class, msg, e.backtrace
        end
      end

      def fetch_access(secret)
        token = storage.get(access_key(secret))
        refresh_token = storage.get(refresh_key(secret))
        token.nil? ? {} : { token: token, refresh_token: refresh_token }
      end

      def persist_access(secret, token, refresh_token, expiration)
        update_data(secret, token, refresh_token, expiration)
      end

      def update_access(secret, token, refresh_token, expiration)
        update_data(secret, token, refresh_token, expiration)
      end

      def access_expired?(secret)
        access_key = access_key(secret)
        refresh_key = refresh_key(secret)
        storage.get(refresh_key) && storage.get(access_key).nil?
      end

      private

      def update_data(secret, token, refresh_token, expiration)
        access_key = access_key(secret)
        refresh_key = refresh_key(secret)
        storage.set(access_key, token)
        storage.set(refresh_key, refresh_token)
        storage.expireat(access_key, expiration)
      end

      def configure_redis_client(redis_url: nil, redis_host: nil, redis_port: nil, redis_db_name: nil)
        if redis_url && (redis_host || redis_port || redis_db_name)
          raise ArgumentError, 'redis_url cannot be passed along with redis_host, redis_port or redis_db_name options'
        end

        redis_url ||= build_redis_url(
          redis_host: redis_host,
          redis_port: redis_port,
          redis_db_name: redis_db_name
        )

        Redis.new(url: redis_url)
      end

      def build_redis_url(redis_host: nil, redis_port: nil, redis_db_name: nil)
        redis_db_name ||= Amorail.config.redis_db_name
        return URI.join(Amorail.config.redis_url, redis_db_name).to_s if Amorail.config.redis_url

        redis_host ||= Amorail.config.redis_host
        redis_port ||= Amorail.config.redis_port

        redis_base_url = ENV['REDIS_URL'] || "redis://#{redis_host}:#{redis_port}"
        URI.join(redis_base_url, redis_db_name).to_s
      end

      def access_key(secret)
        "access_#{secret}"
      end

      def refresh_key(secret)
        "refresh_#{secret}"
      end
    end
  end
end
