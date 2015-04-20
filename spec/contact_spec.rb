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

  describe "#save and #update" do
    let(:contact) { Amorail::AmoContact.new(name: "test2") }

    before { contact_update_stub(Amorail.config.api_endpoint) }

    it "return true after update" do
      contact_create_stub(Amorail.config.api_endpoint)
      contact.save!
      contact_update_stub(Amorail.config.api_endpoint)
      contact.name = "foo"
      expect(contact.save!).to be_truthy
      expect(contact.name).to eq "foo"
    end

    it "#update" do
      obj = Amorail::AmoContact.find(101)
      res = obj.update(name: 'Ivan')
      expect(res).to be_truthy
      expect(obj.name).to eq "Ivan"
    end

    it "#update! raise error if id is blank?" do
      obj = Amorail::AmoContact.new
      expect { obj.update!(name: 'Igor') }.to raise_error
    end

    it "#update! by find" do
      obj = Amorail::AmoContact.find(101)
      res = obj.update!(name: "Igor")
      expect(res).to be_truthy
      expect(obj.name).to eq "Igor"
    end

    it "#update! raise error" do
      obj = Amorail::AmoContact.new
      expect { obj.update!(id: 101, name: "Igor") }
        .to(raise_error)
    end
  end
end