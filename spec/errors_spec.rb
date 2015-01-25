require 'spec_helper'

describe Amorail::Client do

  before(:all) do
    ENV['AMORAIL_CONF'] = './spec/fixtures/amorail_test.yml'
  end

  it 'should return 401 error (if user unauthorized)' do
    client = Amorail.client
    client.cookies = nil
    expect{client.get('/private/api/v2/json/accounts/current')}.to raise_error(AmoUnauthorizedError)
  end

  it 'should return if bad request' do
    client = Amorail.client
    client.authorize
    expect{client.post('/private/api/v2/json/accounts/current')}.to raise_error(AmoBadRequestError)
  end
end