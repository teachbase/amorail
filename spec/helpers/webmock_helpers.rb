# frozen_string_literal: true

# rubocop: disable Metrics/ModuleLength
module AmoWebMock
  def mock_api
    authorize_stub(
      Amorail.config.api_endpoint,
      Amorail.config.client_id,
      Amorail.config.client_secret,
      'authorization_code',
      Amorail.config.code,
      Amorail.config.redirect_uri
    )

    resresh_token_stub(
      Amorail.config.api_endpoint,
      Amorail.config.client_id,
      Amorail.config.client_secret,
      'refresh_token',
      'refresh_token',
      Amorail.config.redirect_uri
    )

    account_info_stub(Amorail.config.api_endpoint)
  end

  def mock_custom_api(endpoint, client_id, client_secret, code, redirect_uri, properties = 'response_2.json')
    authorize_stub(
      endpoint,
      client_id,
      client_secret,
      'authorization_code',
      code,
      redirect_uri
    )

    resresh_token_stub(
      endpoint,
      client_id,
      client_secret,
      'refresh_token',
      'refresh_token',
      redirect_uri
    )

    account_info_stub(endpoint, properties)
  end

  def authorize_stub(endpoint, client_id, client_secret, grant_type, code, redirect_uri)
    stub_request(:post, "#{endpoint}/oauth2/access_token")
      .with(
        body: "{\"client_id\":\"#{client_id}\",\"client_secret\":\"#{client_secret}\",\"grant_type\":\"#{grant_type}\",\"code\":\"#{code}\",\"redirect_uri\":\"#{redirect_uri}\"}"
      )
      .to_return(
        status: 200,
        body: File.read('./spec/fixtures/authorize.json'),
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def resresh_token_stub(endpoint, client_id, client_secret, grant_type, refresh_token, redirect_uri)
    stub_request(:post, "#{endpoint}/oauth2/access_token")
        .with(
            body: "{\"client_id\":\"#{client_id}\",\"client_secret\":\"#{client_secret}\",\"grant_type\":\"#{grant_type}\",\"refresh_token\":\"#{refresh_token}\",\"redirect_uri\":\"#{redirect_uri}\"}"
        )
        .to_return(
            status: 200,
            body: File.read('./spec/fixtures/authorize_refresh_token.json'),
            headers: { 'Content-Type' => 'application/json' }
        )
  end

  def account_info_stub(endpoint, properties = 'response_1.json')
    stub_request(:get, endpoint + '/private/api/v2/json/accounts/current')
      .to_return(
        body: File.read("./spec/fixtures/accounts/#{properties}"),
        headers: { 'Content-Type' => 'application/json' },
        status: 200
      )
  end

  def unauthorized_account_info_stub(endpoint)
    stub_request(:get, endpoint + '/private/api/v2/json/accounts/current')
      .to_return(
        body: "", status: 401
      )
  end

  def bad_req_account_info_stub(endpoint)
    stub_request(:post, endpoint + '/private/api/v2/json/accounts/current')
      .with(body: "{}")
      .to_return(
        body: "",
        status: 400
      )
  end

  def contact_create_stub(endpoint)
    stub_request(:post, endpoint + '/private/api/v2/json/contacts/set')
      .to_return(
        body: File.read('./spec/fixtures/contacts/create.json'),
        headers: { 'Content-Type' => 'application/json' },
        status: 200
      )
  end

  def contact_update_stub(endpoint)
    stub_request(:post, endpoint + '/private/api/v2/json/contacts/set')
      .to_return(
        body: File.read('./spec/fixtures/contacts/update.json'),
        headers: {
          'Content-Type' => 'application/json'
        },
        status: 200
      )
  end

  def contact_find_stub(endpoint, id, success = true)
    if success
      stub_request(
        :get,
        "#{endpoint}/private/api/v2/json/contacts/list?id=#{id}")
        .to_return(
          body: File.read('./spec/fixtures/contacts/find_one.json'),
          headers: { 'Content-Type' => 'application/json' },
          status: 200
        )
    else
      stub_request(
        :get,
        "#{endpoint}/private/api/v2/json/contacts/list?id=#{id}")
        .to_return(body: nil, status: 204)
    end
  end

  def my_contact_find_stub(endpoint, id, success = true)
    if success
      stub_request(
        :get,
        "#{endpoint}/private/api/v2/json/contacts/list?id=#{id}")
        .to_return(
          body: File.read('./spec/fixtures/contacts/my_contact_find.json'),
          headers: { 'Content-Type' => 'application/json' },
          status: 200
        )
    else
      stub_request(
        :get,
        "#{endpoint}/private/api/v2/json/contacts/list?id=#{id}")
        .to_return(body: nil, status: 204)
    end
  end

  def contacts_find_query_stub(endpoint, query, success = true)
    if success
      stub_request(
        :get,
        "#{endpoint}/private/api/v2/json/contacts/list?query=#{query}")
        .to_return(
          body: File.read('./spec/fixtures/contacts/find_many.json'),
          headers: { 'Content-Type' => 'application/json' },
          status: 200
        )
    else
      stub_request(
        :get,
        "#{endpoint}/private/api/v2/json/contacts/list?query=#{query}")
        .to_return(status: 204)
    end
  end

  def contacts_find_all_stub(endpoint, ids, success = true)
    if success
      stub_request(
        :get,
        "#{endpoint}/private/api/v2/json/contacts/list?#{ids.to_query('id')}")
        .to_return(
          body: File.read('./spec/fixtures/contacts/find_many.json'),
          headers: { 'Content-Type' => 'application/json' },
          status: 200
        )
    else
      stub_request(
        :get,
        "#{endpoint}/private/api/v2/json/contacts/list?#{ids.to_query('id')}")
        .to_return(status: 204)
    end
  end

  def contacts_where_stub(endpoint, success = true, **params)
    if success
      stub_request(
        :get,
        "#{endpoint}/private/api/v2/json/contacts/list"
      ).with(
        query: params
      ).to_return(
        body: File.read('./spec/fixtures/contacts/find_many.json'),
        headers: { 'Content-Type' => 'application/json' },
        status: 200
      )
    else
      stub_request(
        :get,
        "#{endpoint}/private/api/v2/json/contacts/list?query=#{query}")
        .to_return(status: 204)
    end
  end

  def company_create_stub(endpoint)
    stub_request(:post, endpoint + '/private/api/v2/json/company/set')
      .to_return(
        body: File.read('./spec/fixtures/contacts/create.json'),
        headers: { 'Content-Type' => 'application/json' },
        status: 200
      )
  end

  def leads_stub(endpoint, ids, success = true)
    if success
      stub_request(
        :get,
        "#{endpoint}/private/api/v2/json/leads/list?#{ids.to_query('id')}")
        .to_return(
          body: File.read('./spec/fixtures/leads/find_many.json'),
          headers: { 'Content-Type' => 'application/json' },
          status: 200
        )
    else
      stub_request(
        :get,
        "#{endpoint}/private/api/v2/json/leads/list?#{ids.to_query('id')}")
        .to_return(status: 204)
    end
  end

  def lead_create_stub(endpoint)
    stub_request(:post, endpoint + '/private/api/v2/json/leads/set')
      .to_return(
        body: File.read('./spec/fixtures/leads/create.json'),
        headers: { 'Content-Type' => 'application/json' },
        status: 200
      )
  end

  def lead_update_stub(endpoint, success = true)
    fixture_file =
      if success
        './spec/fixtures/leads/update.json'
      else
        './spec/fixtures/leads/update_errors.json'
      end

    stub_request(:post, endpoint + '/private/api/v2/json/leads/set')
      .to_return(
        body: File.read(fixture_file),
        headers: {
          'Content-Type' => 'application/json'
        },
        status: 200
      )
  end

  def contacts_links_stub(endpoint, ids)
    stub_request(:get, endpoint + "/private/api/v2/json/contacts/links?#{ids.to_query('contacts_link')}")
      .to_return(
        body: File.read('./spec/fixtures/contacts/links.json'),
        headers: { 'Content-Type' => 'application/json' },
        status: 200
      )
  end

  def leads_links_stub(endpoint, ids, success = true)
    if success
      stub_request(:get, endpoint + "/private/api/v2/json/contacts/links?#{ids.to_query('deals_link')}")
        .to_return(
          body: File.read('./spec/fixtures/leads/links.json'),
          headers: { 'Content-Type' => 'application/json' },
          status: 200
        )
    else
      stub_request(:get, endpoint + "/private/api/v2/json/contacts/links?#{ids.to_query('deals_link')}")
        .to_return(status: 204)
    end
  end

  def webhooks_list_stub(endpoint, empty: false)
    body = empty ? '' : File.read('./spec/fixtures/webhooks/list.json')
    stub_request(:get, "#{endpoint}/private/api/v2/json/webhooks/list")
      .to_return(
        body: body,
        headers: { 'Content-Type' => 'application/json' },
        status: 200
      )
  end

  def webhooks_subscribe_stub(endpoint, webhooks)
    stub_request(:post, "#{endpoint}/private/api/v2/json/webhooks/subscribe")
      .with(body: { request: { webhooks: { subscribe: webhooks } } }.to_json)
      .to_return(
        body: File.read('./spec/fixtures/webhooks/subscribe.json'),
        headers: { 'Content-Type' => 'application/json' },
        status: 200
      )
  end

  def webhooks_unsubscribe_stub(endpoint, webhooks)
    stub_request(:post, "#{endpoint}/private/api/v2/json/webhooks/unsubscribe")
      .with(body: { request: { webhooks: { unsubscribe: webhooks } } }.to_json)
      .to_return(
        body: File.read('./spec/fixtures/webhooks/unsubscribe.json'),
        headers: { 'Content-Type' => 'application/json' },
        status: 200
      )
  end
end
