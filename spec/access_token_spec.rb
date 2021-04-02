# frozen_string_literal: true

require "spec_helper"

describe Amorail::AccessToken do
  let(:access_token) do
    Amorail::AccessToken.create(
      'secret',
      'token',
      'refresh_token',
      Time.now.to_i + 86_000,
      Amorail.token_store
    )
  end

  let(:expired_access_token) do
    Amorail::AccessToken.create(
      'secret_expired',
      'token',
      'refresh_token',
      Time.now.to_i - 92_000,
      Amorail.token_store
    )
  end

  describe '#find' do
    context 'when token is not expired' do
      it 'should return token' do
        token = Amorail.token_store.fetch_access(access_token.secret)
        expect(token[:token]).to eq(access_token.token)
      end
    end

    context 'when token is expired' do
      it 'should return nil' do
        token = Amorail.token_store.fetch_access(expired_access_token.secret)
        expect(token[:token]).to be_nil
      end
    end
  end

  describe '#refresh' do
    it 'updates token data in storage' do
      access_token = Amorail::AccessToken.refresh('secret',
                                                  'upd_token',
                                                  'upd_refresh',
                                                  Time.now.to_i + 96_000,
                                                  Amorail.token_store)
      expect(access_token.token).to eq('upd_token')
    end
  end
end
