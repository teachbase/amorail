# frozen_string_literal: true

require "spec_helper"

describe Amorail::AccessToken do
  let(:store) { Amorail.token_store }

  before do
    Amorail::AccessToken.create(
      'secret',
      'token',
      'refresh_token',
      Time.now.to_i + 86_000,
      store
    )

    Amorail::AccessToken.create(
      'secret_expired',
      'token',
      'refresh_token',
      Time.now.to_i - 92_000,
      store
    )
  end

  describe '#find' do
    context 'when token is not expired' do
      subject { Amorail::AccessToken.find('secret', store).token }

      it 'should return token' do
        expect(subject).to eq('token')
      end
    end

    context 'when token is expired' do
      subject { Amorail::AccessToken.find('secret_expired', store).token }

      it 'should return nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#refresh' do
    it 'updates token data' do
      upd_expiration = Time.now.to_i + 96_000
      access_token = Amorail::AccessToken.refresh('secret',
                                                  'upd_token',
                                                  'upd_refresh',
                                                  upd_expiration,
                                                  Amorail.token_store)
      aggregate_failures do
        expect(access_token.token).to eq('upd_token')
        expect(access_token.refresh_token).to eq('upd_refresh')
        expect(access_token.expiration).to eq(upd_expiration)
      end
    end
  end
end
