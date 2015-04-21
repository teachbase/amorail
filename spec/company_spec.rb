require "spec_helper"

describe Amorail::AmoCompany do
  before { mock_api }
  
  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "#params" do
    let(:company) do
      Amorail::AmoCompany.new(
        name: 'Test inc',
        phone: '12345678',
        email: 'test@mala.ru',
        address: '10, State st',
        web: 'hoohle.com'
      )
    end

    subject { company.params }

    specify { is_expected.to include(name: 'Test inc') }
    specify { is_expected.to include(type: 'contact') }

    it "contains email property" do
      prop = subject[:custom_fields].detect { |p| p[:id] == "1460591" }
      expect(prop).not_to be_nil
      expect(prop[:values].first[:value]).to eq 'test@mala.ru'
      expect(prop[:values].first[:enum]).to eq 'WORK'
    end

    it "contains phone property" do
      prop = subject[:custom_fields].detect { |p| p[:id] == "1460589" }
      expect(prop).not_to be_nil
      expect(prop[:values].first[:value]).to eq '12345678'
      expect(prop[:values].first[:enum]).to eq 'WORK'
    end

    it "contains address property" do
      prop = subject[:custom_fields].detect { |p| p[:id] == "1460597" }
      expect(prop).not_to be_nil
      expect(prop[:values].first[:value]).to eq '10, State st'
    end

    it "contains web property" do
      prop = subject[:custom_fields].detect { |p| p[:id] == "1460593" }
      expect(prop).not_to be_nil
      expect(prop[:values].first[:value]).to eq 'hoohle.com'
    end
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
