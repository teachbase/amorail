require "spec_helper"

describe MyContact do
  before { mock_api }

  describe ".properties" do
    subject { described_class.properties }

    specify do
      is_expected.to include(:email, :phone, :teachbase_id)
    end
  end

  describe "#params" do
    let(:company) do
      described_class.new(
        name: 'Test inc',
        phone: '12345678',
        email: 'test@mala.ru',
        teachbase_id: 123
      )
    end

    subject { company.params }

    specify { is_expected.to include(:last_modified) }
    specify { is_expected.to include(name: 'Test inc') }

    it "contains custom property" do
      prop = subject[:custom_fields].detect { |p| p[:id] == "116302" }
      expect(prop).not_to be_nil
      expect(prop[:values].first[:value]).to eq 123
    end
  end

  describe ".find" do
    before { my_contact_find_stub(Amorail.config.api_endpoint, 11) }

    it "loads entity" do
      obj = described_class.find(11)
      expect(obj.id).to eq 11
      expect(obj.company_name).to eq "Foo Inc."
      expect(obj.email).to eq "foo@tb.com"
      expect(obj.teachbase_id).to eq 1123
      expect(obj.params[:id]).to eq 11
    end
  end
end
