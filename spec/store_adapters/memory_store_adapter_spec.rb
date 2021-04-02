# frozen_string_literal: true

require 'spec_helper'

describe Amorail::StoreAdapters::MemoryStoreAdapter do
  let(:store) { Amorail::StoreAdapters.build_by_name(:memory) }

  describe '#initialize' do
    it 'raises error on unknow option' do
      expect { Amorail::StoreAdapters::MemoryStoreAdapter.new(something: 'something') }.to raise_error(ArgumentError)
    end
  end

  describe '#persist_access' do
    context 'when token not expired' do
      it 'save record to memory' do
        expiration = (Time.now + 86_000).to_i
        store.persist_access('secret', 'token', 'refresh_token', expiration)
        expect(store.fetch_access('secret')).to eq({ token: 'token', refresh_token: 'refresh_token', expiration: expiration })
      end
    end

    context 'when token is expired' do
      it 'return blank hash' do
        expiration = (Time.now - 86_000).to_i
        store.persist_access('secret', 'token', 'refresh_token', expiration)
        expect(store.fetch_access('secret')).to eq({})
      end
    end
  end

  describe '#update_access' do
    it 'refresh token data' do
      expiration = (Time.now + 86_000).to_i
      upd_expiration = (Time.now + 92_000).to_i
      store.persist_access('secret', 'token', 'refresh_token', expiration)
      store.update_access('secret', 'upd_token', 'upd_refresh', upd_expiration)
      expect(store.fetch_access('secret')).to eq({ token: 'upd_token', refresh_token: 'upd_refresh', expiration: upd_expiration })
    end
  end
end
