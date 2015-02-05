require "spec_helper"

describe Amorail::AmoContact do
  before { mock_api }
  
  describe "validations" do
    it { should validate_presence_of(:name)}
  end

  describe "#save" do
    let(:contact) { Amorail::AmoContact.new(name: "test") }

    before { contact_create_stub(Amorail.config.api_endpoint) }

    it "should set id after create" do
      contact.save!
      expect(contact.id).to eq 101
    end
  end
end