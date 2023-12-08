# frozen_string_literal: true

require 'spec_helper'

describe Amorail::StoreAdapters::MemoryStoreAdapter do
  let!(:expiration) { Time.now.to_i + 86_000 }
  let(:store) { Amorail::StoreAdapters.build_by_name(:memory) }

  describe '#initialize' do
    it 'raises error on unknow option' do
      expect { Amorail::StoreAdapters::MemoryStoreAdapter.new(something: 'something') }.to raise_error(ArgumentError)
    end
  end

  describe '#persist_access' do
    subject { store.persist_access('secret', 'token', 'refresh_token', expiration) }

    it 'save record to memory' do
      expect { subject }.to change { store.fetch_access('secret') }.from(
        {}
      ).to(
        { token: 'token', refresh_token: 'refresh_token', expiration: expiration }
      )
    end
  end

  describe '#fetch_access' do
    context 'when token not expired' do
      it 'returns valid data' do
        store.persist_access('secret', 'token', 'refresh_token', expiration)
        expect(store.fetch_access('secret')).to eq({ token: 'token', refresh_token: 'refresh_token', expiration: expiration })
      end
    end

    context 'when token is expired' do
      it 'returns blank hash' do
        store.persist_access('secret', 'token', 'refresh_token', Time.now.to_i - 10_000)
        expect(store.fetch_access('secret')).to eq(refresh_token: 'refresh_token')
      end
    end
  end

  describe '#update_access' do
    let!(:upd_expiration) { Time.now.to_i + 92_000 }
    subject { store.update_access('secret', 'upd_token', 'upd_refresh', upd_expiration) }

    it 'refresh token data' do
      store.persist_access('secret', 'token', 'refresh_token', expiration)
      expect { subject }.to change { store.fetch_access('secret') }.from(
        { token: 'token', refresh_token: 'refresh_token', expiration: expiration }
      ).to(
        { token: 'upd_token', refresh_token: 'upd_refresh', expiration: upd_expiration }
      )
    end
  end
end
