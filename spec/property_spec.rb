require "spec_helper"
require "webmock/rspec"

describe Amorail::Property do
  before(:each) { mock_api }

  let(:prop) { Amorail.properties }

  it "should parse companies hash" do
    expect(prop.company.phone.present?).to be_truthy
    expect(prop.company.phone.is_a?(described_class::PropertyItem)).to be_truthy
    expect(prop.company.phone.id.present?).to be_truthy
    expect(prop.company.data["phone"].data["id"]).to eq prop.company.phone.id

    expect(prop.company.phone.id).to eq "1460589"
    expect(prop.company.address.id).to eq "1460597"
    expect(prop.company.email.id).to eq "1460591"
    expect(prop.company.web.id).to eq "1460593"
  end

  it "should parse contacts hash" do
    expect(prop.contacts.email.present?).to be_truthy
    expect(prop.contacts.im.is_a?(described_class::PropertyItem)).to be_truthy
    expect(prop.contacts.im.id.present?).to be_truthy
    expect(prop.contacts.data["im"].data["id"]).to eq prop.contacts.im.id

    expect(prop.contacts.im.id).to eq "1460595"
    expect(prop.contacts.position.id).to eq "1460587"
    expect(prop.contacts.phone.id).to eq "1460589"
    expect(prop.contacts.email.id).to eq "1460591"
    expect(prop.contacts.teachbase_id.id).to eq "116302"
  end

  it "should parse leads hash" do
    expect(prop.leads.textfield.id).to eq "484604"
    expect(prop.leads.flag.id).to eq "484606"
    expect(prop.leads.statuses["Первичный контакт"].id).to eq "8195972"
    expect(prop.leads.statuses["Успешно реализовано"].id).to eq "142"
  end

  it "should parse task types" do
    expect(prop.tasks.follow_up.id).to eq 1
    expect(prop.tasks["CALL"].id).to eq 1
  end
end
