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
    res = client.authorize
    expect(res.status).to eq 200
  end

  it "should #authorize and set cookie" do
    res = client.get("/private/api/v2/json/accounts/current")
    expect(res.status).to eq 200
  end
end
