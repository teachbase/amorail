require "spec_helper"

describe Amorail::Client do

  before(:all) do
    ENV["AMORAIL_CONF"] = "./spec/fixtures/amorail_test.yml"
  end

  let(:client) {Amorail.client}

  before(:each) do
    authorize_stub(Amorail.config.api_endpoint, 
      Amorail.config.usermail, 
      Amorail.config.api_key)
    
    account_info_stub(Amorail.config.api_endpoint)
  end

  it "it should create client with connection" do
    expect(Amorail.config.usermail).to eq "alekseenkoss@gmail.com"
    expect(Amorail.config.api_key).to eq "7132282ce5742b166417fe32ae178cf6"
    expect(Amorail.config.api_endpoint).to eq "https://new54c0b12948ffb.amocrm.ru"
  end

  it "should #authorize method call" do
    res = client.authorize
    expect(res.status).to eq 200
  end

  it "should #authorize and set cookie for other requests" do
    res = client.get("/private/api/v2/json/accounts/current")
    expect(res.status).to eq 200
  end
end