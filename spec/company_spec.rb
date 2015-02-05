require "spec_helper"

describe Amorail::AmoCompany do
  before { mock_api }
  
  describe "validations" do
    it { should validate_presence_of(:name)}
  end

  describe "#save" do
    let(:company) { Amorail::AmoCompany.new(name: "test") }

    before { company_create_stub(Amorail.config.api_endpoint) }

    it "should set id after create" do
      company.save!
      expect(company.id).to eq 101
    end
  end
end