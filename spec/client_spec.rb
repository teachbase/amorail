require 'spec_helper'

describe Amorail::Client do

  before(:all) do
    ENV['AMORAIL_CONF'] = './spec/fixtures/amorail_test.yml'
  end

  it 'it should create client with connection' do
    amo = Amorail.client
    expect(Amorail.config.usermail).to eq     'alekseenkoss@gmail.com'
    expect(Amorail.config.api_key).to eq      '7132282ce5742b166417fe32ae178cf6'
    expect(Amorail.config.api_endpoint).to eq 'https://new54c0b12948ffb.amocrm.ru'
  end
end