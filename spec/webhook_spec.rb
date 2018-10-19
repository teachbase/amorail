require 'spec_helper'

describe Amorail::Webhook do
  before { mock_api }

  describe '.list' do
    context 'there are some webhooks' do
      before { webhooks_list_stub(Amorail.config.api_endpoint) }

      it 'loads webhooks' do
        res = described_class.list
        expect(res.size).to eq 2
        expect(res.first.id).to eq '1'
        expect(res.first.url).to eq 'http://example.org'
        expect(res.first.events).to eq ['add_contact']
        expect(res.first.disabled).to eq false
        expect(res.last.id).to eq '2'
        expect(res.last.url).to eq 'http://example.com'
        expect(res.last.events).to eq ['add_contact', 'add_company']
        expect(res.last.disabled).to eq true
      end
    end

    context 'there are not any webhooks' do
      before { webhooks_list_stub(Amorail.config.api_endpoint, empty: true) }

      it 'returns an empty array' do
        res = described_class.list
        expect(res).to eq []
      end
    end
  end

  describe '.subscribe' do
    it 'creates webhooks' do
      webhooks = [
        { url: 'http://example.org', events: ['add_contact'] },
        { url: 'http://example.com', events: ['add_contact', 'add_company'] }
      ]
      stub = webhooks_subscribe_stub(Amorail.config.api_endpoint, webhooks)
      res = described_class.subscribe(webhooks)
      expect(stub).to have_been_requested
      expect(res.first.url).to eq 'http://example.org'
      expect(res.last.url).to eq 'http://example.com'
    end
  end

  describe '.unsubscribe' do
    it 'removes webhooks' do
      webhooks = [
        { url: 'http://example.org', events: ['add_contact'] },
        { url: 'http://example.com', events: ['add_contact', 'add_company'] }
      ]
      stub = webhooks_unsubscribe_stub(Amorail.config.api_endpoint, webhooks)
      described_class.unsubscribe(webhooks)
      expect(stub).to have_been_requested
    end
  end
end
