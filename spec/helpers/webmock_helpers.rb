# rubocop: disable Metrics/ModuleLength
module AmoWebMock
  def mock_api
    authorize_stub(
      Amorail.config.api_endpoint,
      Amorail.config.usermail,
      Amorail.config.api_key)

    account_info_stub(Amorail.config.api_endpoint)
  end

  def mock_custom_api(endpoint, usermail, api_key, properties = 'account2_response.json')
    authorize_stub(
      endpoint,
      usermail,
      api_key
    )

    account_info_stub(endpoint, properties)
  end

  def authorize_stub(endpoint, usermail, api_key)
    cookie = 'PHPSESSID=58vorte6dd4t7h6mtuig9l0p50; path=/; domain=amocrm.ru'
    stub_request(:post, "#{endpoint}/private/api/auth.php?type=json")
      .with(
        body: "{\"USER_LOGIN\":\"#{usermail}\",\"USER_HASH\":\"#{api_key}\"}"
      )
      .to_return(
        status: 200,
        body: "",
        headers: {
          'Set-Cookie' => cookie
        })
  end

  def account_info_stub(endpoint, properties = 'account_response.json')
    stub_request(:get, endpoint + '/private/api/v2/json/accounts/current')
      .to_return(
        body: File.read("./spec/fixtures/#{properties}"),
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
        body: File.read('./spec/fixtures/contact_create.json'),
        headers: { 'Content-Type' => 'application/json' },
        status: 200
      )
  end

  def contact_update_stub(endpoint)
    stub_request(:post, endpoint + '/private/api/v2/json/contacts/set')
      .to_return(
        body: File.read('./spec/fixtures/contact_update.json'),
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
          body: File.read('./spec/fixtures/contact_find.json'),
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
          body: File.read('./spec/fixtures/my_contact_find.json'),
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
          body: File.read('./spec/fixtures/contact_find_query.json'),
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
          body: File.read('./spec/fixtures/contact_find_query.json'),
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

  def company_create_stub(endpoint)
    stub_request(:post, endpoint + '/private/api/v2/json/company/set')
      .to_return(
        body: File.read('./spec/fixtures/contact_create.json'),
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
          body: File.read('./spec/fixtures/leads.json'),
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

  def contacts_links_stub(endpoint, ids)
    stub_request(:get, endpoint + "/private/api/v2/json/contacts/links?#{ids.to_query('contacts_link')}")
      .to_return(
        body: File.read('./spec/fixtures/contacts_links.json'),
        headers: { 'Content-Type' => 'application/json' },
        status: 200
      )
  end

  def leads_links_stub(endpoint, ids, success = true)
    if success
      stub_request(:get, endpoint + "/private/api/v2/json/contacts/links?#{ids.to_query('deals_link')}")
        .to_return(
          body: File.read('./spec/fixtures/leads_links.json'),
          headers: { 'Content-Type' => 'application/json' },
          status: 200
        )
    else
      stub_request(:get, endpoint + "/private/api/v2/json/contacts/links?#{ids.to_query('deals_link')}")
        .to_return(status: 204)
    end
  end
end
