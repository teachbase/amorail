module Amorail
  class Webhook < Entity
    amo_names 'webhooks'

    amo_field :id, :url, :events, :disabled

    def self.list
      response = client.safe_request(:get, remote_url('list'))

      return [] if response.body.blank?

      response.body['response'].fetch(amo_response_name, []).map { |attributes| new.reload_model(attributes) }
    end

    def self.subscribe(webhooks)
      perform_webhooks_request('subscribe', webhooks) { |data| data.map { |attrs| new.reload_model(attrs) } }
    end

    def self.unsubscribe(webhooks)
      perform_webhooks_request('unsubscribe', webhooks)
    end

    def self.perform_webhooks_request(action, webhooks, &block)
      response = client.safe_request(:post, remote_url(action), request: { webhooks: { action => webhooks } })
      block.call(response.body['response'].dig(amo_response_name, 'subscribe')) if block
    end

    private_class_method :perform_webhooks_request
  end
end
