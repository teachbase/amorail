# frozen_string_literal: true

require "spec_helper"

describe Amorail::Client do
  let(:client) { Amorail.client }

  before(:each) { mock_api }

  context "default client" do
    it "should create client", :aggregate_failures do
      expect(subject.client_id).to eq "some_id"
      expect(subject.client_secret).to eq "some_secret"
      expect(subject.code).to eq "some_code"
      expect(subject.redirect_uri).to eq "https://example.ru/redirect/uri"
      expect(subject.api_endpoint).to eq "https://test.amocrm.ru"
    end

    it "should #authorize method call" do
      res = client.authorize
      expect(res.status).to eq 200
    end

    it "should #authorize and set cookie" do
      res = client.get("/private/api/v2/json/accounts/current")
      expect(res.status).to eq 200
    end
  end

  describe "#with_client" do
    before { mock_custom_api("https://custom.amo.com", "custom_client_id", "custom_client_secret", "custom_code", "https://custom-site.ru/redirecto/uri") }

    let(:new_client) do
      described_class.new(
        api_endpoint: "https://custom.amo.com",
        client_secret: "custom_client_secret",
        client_id: "custom_client_id",
        code: "custom_code",
        redirect_uri: "https://custom-site.ru/redirecto/uri"
      )
    end

    it "use custom client as instance", :aggregate_failures do
      expect(Amorail.client.client_id).to eq "some_id"
      Amorail.with_client(new_client) do
        expect(Amorail.client.client_secret).to eq "custom_client_secret"
        expect(Amorail.client.client_id).to eq "custom_client_id"
        expect(Amorail.client.api_endpoint).to eq "https://custom.amo.com"
        expect(Amorail.client.code).to eq "custom_code"
        expect(Amorail.client.redirect_uri).to eq "https://custom-site.ru/redirecto/uri"
      end

      expect(Amorail.client.client_id).to eq "some_id"
    end

    it "use custom client as options", :aggregate_failures do
      expect(Amorail.client.client_id).to eq "some_id"
      Amorail.with_client(
        api_endpoint: "https://custom.amo.com",
        client_secret: "custom_client_secret",
        client_id: "custom_client_id",
        code: "custom_code",
        redirect_uri: "https://custom-site.ru/redirecto/uri"
      ) do
        expect(Amorail.client.client_secret).to eq "custom_client_secret"
        expect(Amorail.client.client_id).to eq "custom_client_id"
        expect(Amorail.client.api_endpoint).to eq "https://custom.amo.com"
        expect(Amorail.client.code).to eq "custom_code"
        expect(Amorail.client.redirect_uri).to eq "https://custom-site.ru/redirecto/uri"
      end

      expect(Amorail.client.client_id).to eq "some_id"
    end

    it "loads custom properties", :aggregate_failures do
      expect(Amorail.properties.company.phone.id).to eq "1460589"

      Amorail.with_client(new_client) do
        expect(Amorail.properties.company.phone.id).to eq "301"
      end

      expect(Amorail.properties.company.phone.id).to eq "1460589"
    end

    it "threadsafe", :aggregate_failures do
      results = []
      q1 = Queue.new
      q2 = Queue.new
      q3 = Queue.new
      threads = []

      # This thread enters block first but commits result
      # only after the second thread enters block
      threads << Thread.new do
        q1.pop
        Amorail.with_client(client_id: 'some_id_1') do
          q2 << 1
          q1.pop
          results << Amorail.client.client_id
          q2 << 1
        end
        q3 << 1
      end

      # This thread enters block second and commits result
      # after the first block
      threads << Thread.new do
        q2.pop
        Amorail.with_client(client_id: 'some_id_2') do
          q1 << 1
          q2.pop
          results << Amorail.client.client_id
        end
        q3 << 1
      end

      # This thread enters block third and commits
      # after all other threads left blocks
      threads << Thread.new do
        Amorail.with_client(client_id: 'some_id_3') do
          q3.pop
          q3.pop
          results << Amorail.client.client_id
        end
      end

      q1 << 1
      threads.each(&:join)

      expect(results[0]).to eq 'some_id_1'
      expect(results[1]).to eq 'some_id_2'
      expect(results[2]).to eq 'some_id_3'
    end
  end

  describe '#safe_request' do
    subject(:safe_request) { client.safe_request(:get, '/private/api/v2/json/accounts/current') }

    let(:response) { instance_double('Faraday::Response', body: {}, status: 200) }
    let(:client) { described_class.new }
    let(:access_token) { 'eyJ0eXAiOiJKf2QihCJhbGciOiJSUzI1NiIsImp0aSI6IjMxMT' }

    # We need to refresh the token store before the initial safe_request
    # to test that it performs authorization
    before { Amorail.token_store = :memory }

    it 'authorizes the client if there is no access token' do
      expect { safe_request }.to change { client.access_token }.from(nil).to(start_with(access_token))
    end

    context 'when access token is expired' do
      let(:renewed_access_token) { '50d084c7efbd911f0a9d03bb387f3ad4dc092be253' }

      before do
        Amorail.token_store.persist_access(
          Amorail.config.client_secret,
          'old_access_token',
          'refresh_token',
          Time.now.to_i - 10
        )
      end

      it 'refreshes authorization token' do
        expect { safe_request }.to change { client.access_token }.from(nil).to(
          start_with(renewed_access_token)
        )
      end
    end
  end
end
