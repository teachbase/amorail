require "spec_helper"

describe Amorail::Client do
  let(:client) { Amorail.client }

  before(:each) { mock_api }

  it "it should create client" do
    expect(Amorail.config.usermail).to eq "amorail@test.com"
    expect(Amorail.config.api_key).to eq "75742b166417fe32ae132282ce178cf6"
    expect(Amorail.config.api_endpoint).to eq "https://test.amocrm.ru"
  end

  it "should #authorize method call" do
    stub_request(:post, "https://test.amocrm.ru/private/api/auth.php?type=json").
        with(:body => "{\"USER_LOGIN\":\"\",\"USER_HASH\":\"\"}",
             :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(:status => 200, :body => "", :headers => {})
  end

  it "should #authorize and set cookie" do
    res = client.get("/private/api/v2/json/accounts/current")
    expect(res.status).to eq 200
  end
end
