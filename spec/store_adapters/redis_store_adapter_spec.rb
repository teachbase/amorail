# frozen_string_literal: true

require 'spec_helper'

describe Amorail::StoreAdapters::RedisStoreAdapter do
  before :each do
    Amorail.config.reload
  end

  let(:store) { Amorail::StoreAdapters.build_by_name(:redis) }

  describe '#initialize' do
    it 'raises error on mixed redis options' do
      expect { Amorail::StoreAdapters::RedisStoreAdapter.new(redis_url: 'redis://127.0.0.1:6379/0',
                                                             redis_port: '8082') }.to raise_error(ArgumentError)
    end

    it 'raises error on unknown options' do
      expect { Amorail::StoreAdapters::RedisStoreAdapter.new(redis_url: 'redis://127.0.0.1:6379/0',
                                                             something: 'smth') }.to raise_error(ArgumentError)
    end
  end

  describe 'configuration' do
    let(:adapter) { Amorail::StoreAdapters::RedisStoreAdapter.new }

    it 'set default url' do
      expect(adapter.storage.id).to eq('redis://127.0.0.1:6379/0')
    end

    it 'set url from env variable' do
      ENV['REDIS_URL'] = 'redis://localhost:2020/'
      adapter = Amorail::StoreAdapters::RedisStoreAdapter.new
      expect(adapter.storage.id).to eq('redis://localhost:2020/0')

      ENV.delete('REDIS_URL')
      adapter = Amorail::StoreAdapters::RedisStoreAdapter.new
      expect(adapter.storage.id).to eq('redis://127.0.0.1:6379/0')
    end

    it 'configuration via host post and db' do
      adapter = Amorail::StoreAdapters::RedisStoreAdapter.new(
          redis_host: '127.0.0.2',
          redis_port: '6372',
          redis_db_name: '2'
      )
      expect(adapter.storage.id).to eq('redis://127.0.0.2:6372/2')
    end

    it 'configuration via host port and db in module' do
      Amorail.config.redis_host = '127.0.0.2'
      Amorail.config.redis_port = '6372'
      Amorail.config.redis_db_name = '2'
      expect(adapter.storage.id).to eq('redis://127.0.0.2:6372/2')
    end

    it 'configuration via redis url' do
      adapter = Amorail::StoreAdapters::RedisStoreAdapter.new(redis_url: 'redis://127.0.0.2:6322')
      expect(adapter.storage.id).to eq('redis://127.0.0.2:6322/0')
    end

    it 'configuration via redis url in module' do
      Amorail.config.redis_url = 'redis://127.0.0.2:6322'
      expect(adapter.storage.id).to eq('redis://127.0.0.2:6322/0')
    end
  end
end
