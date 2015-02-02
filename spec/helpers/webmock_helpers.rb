def authorize_stub(endpoint, usermail, api_key)
  stub_request(:post, "#{endpoint}/private/api/auth.php?type=json").
         with(:body => "{\"USER_LOGIN\":\"#{usermail}\",\"USER_HASH\":\"#{api_key}\"}",
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.9.1'}).
         to_return(:status => 200, :body => "", :headers => {'Set-Cookie' => 'PHPSESSID=58vorte6dd4t7h6mtuig9l0p50; path=/; domain=amocrm.ru'})
end

def account_info_stub(endpoint)
  stub_request(:get, endpoint + '/private/api/v2/json/accounts/current').with(:body => "{}",
                  :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.9.1'}).to_return(
            :body => File.read('./spec/fixtures/account_response.json'), status: 200
          )
end

def unauthorized_account_info_stub(endpoint)
  stub_request(:get, endpoint + '/private/api/v2/json/accounts/current').with(:body => "{}",
          :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.9.1'}).to_return(
    :body => "", status: 401
  )
end

def bad_req_account_info_stub(endpoint)
  stub_request(:post, endpoint + '/private/api/v2/json/accounts/current').with(:body => "{}",
          :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.9.1'}).to_return(
    :body => "", status: 400
  )
end