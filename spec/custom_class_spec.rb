require 'spec_helper'

describe 'spec for Amorail Properties' do

  before(:all) do
    ENV['AMORAIL_CONF'] = './spec/fixtures/amorail_test.yml'
  end

  let(:prop) {Amorail.properties}

  it 'should parse companies hash' do
    expect(prop.company.data.is_a?(Hash)).to be_truthy
    expect(prop.company.phone.present?).to be_truthy
    expect(prop.company.phone.is_a?(Amorail::Property::PropertyItem)).to be_truthy
    expect(prop.company.phone.id.present?).to be_truthy
    expect(prop.company.data['phone'].data['id']).to eq prop.company.phone.id
  end

  it 'should parse contacts hash' do
    expect(prop.contact.data.is_a?(Hash)).to be_truthy
    expect(prop.contact.email.present?).to be_truthy
    expect(prop.contact.im.is_a?(Amorail::Property::PropertyItem)).to be_truthy
    expect(prop.contact.im.id.present?).to be_truthy
    expect(prop.contact.data['im'].data['id']).to eq prop.contact.im.id
  end

  it 'should parse leads hash' do
    expect(prop.lead.data.is_a?(Hash)).to be_truthy
    expect(prop.lead.first_status.id).to eq prop.lead.data['first_status'].data['id']
  end

  it 'should parse task types' do
    expect(prop.task.data.is_a?(Hash)).to be_truthy
    expect(prop.task.data['follow_up'].data['id'].present?).to be_truthy
    expect(prop.task.follow_up.id).to eq prop.task.data['follow_up'].data['id']
  end
end