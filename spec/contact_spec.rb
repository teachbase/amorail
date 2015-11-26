require "spec_helper"

describe Amorail::Contact do
  before { mock_api }

  let(:contact) { described_class.new(name: "test") }

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe ".attributes" do
    subject { described_class.attributes }

    it_behaves_like 'entity_class'

    specify { is_expected.to include(:name, :company_name) }
  end

  describe ".properties" do
    subject { described_class.properties }

    specify { is_expected.to include(:email, :phone, :position) }
  end

  describe "#params" do
    let(:contact) do
      described_class.new(
        name: 'Tester',
        company_name: 'Test inc',
        linked_company_id: 123,
        phone: '12345678',
        email: 'test@mala.ru',
        position: 'CEO'
      )
    end

    subject { contact.params }

    specify { is_expected.to include(:last_modified) }
    specify { is_expected.to include(name: 'Tester') }
    specify { is_expected.to include(company_name: 'Test inc') }
    specify { is_expected.to include(linked_company_id: 123) }

    it "contains email property" do
      prop = subject[:custom_fields].detect { |p| p[:id] == "1460591" }
      expect(prop).not_to be_nil
      expect(prop[:values].first[:value]).to eq 'test@mala.ru'
      expect(prop[:values].first[:enum])
        .to eq described_class.properties[:email][:enum]
    end

    it "contains phone property" do
      prop = subject[:custom_fields].detect { |p| p[:id] == "1460589" }
      expect(prop).not_to be_nil
      expect(prop[:values].first[:value]).to eq '12345678'
      expect(prop[:values].first[:enum])
        .to eq described_class.properties[:phone][:enum]
    end

    it "contains position property" do
      prop = subject[:custom_fields].detect { |p| p[:id] == "1460587" }
      expect(prop).not_to be_nil
      expect(prop[:values].first[:value]).to eq 'CEO'
    end

    it_behaves_like 'leadable'
  end

  describe ".find" do
    before { contact_find_stub(Amorail.config.api_endpoint, 101) }
    before { contact_find_stub(Amorail.config.api_endpoint, 102, false) }

    it "loads entity" do
      obj = described_class.find(101)
      expect(obj.id).to eq 101
      expect(obj.company_name).to eq "Foo Inc."
      expect(obj.email).to eq "foo@tb.com"
      expect(obj.phone).to eq "1111 111 111"
      expect(obj.params[:id]).to eq 101
      expect(obj.linked_leads_id).to contain_exactly("1872746", "1885024")
    end

    it "returns nil" do
      obj = described_class.find(102)
      expect(obj).to be_falsey
    end

    it "raise error" do
      expect { described_class.find!(102) }
        .to raise_error(Amorail::Entity::RecordNotFound)
    end
  end

  describe ".find_by_query" do
    before { contacts_find_query_stub(Amorail.config.api_endpoint, 'foo') }
    before { contacts_find_query_stub(Amorail.config.api_endpoint, 'faa', nil) }

    it "loads entities" do
      res = described_class.find_by_query('foo')
      expect(res.size).to eq 2
      expect(res.first.id).to eq 101
      expect(res.last.id).to eq 102
      expect(res.first.company_name).to eq "Foo Inc."
      expect(res.last.email).to eq "foo2@tb.com"
      expect(res.first.phone).to eq "1111 111 111"
      expect(res.first.params[:id]).to eq 101
    end

    it "returns empty array" do
      res = described_class.find_by_query('faa')
      expect(res).to be_a(Array)
      expect(res).to be_empty
    end
  end

  describe ".find_all" do
    before { contacts_find_all_stub(Amorail.config.api_endpoint, [101, 102]) }
    before { contacts_find_all_stub(Amorail.config.api_endpoint, [105, 104], false) }

    it "loads entities" do
      res = described_class.find_all(101, 102)
      expect(res.size).to eq 2
      expect(res.first.id).to eq 101
      expect(res.last.id).to eq 102
      expect(res.first.company_name).to eq "Foo Inc."
      expect(res.last.email).to eq "foo2@tb.com"
      expect(res.first.phone).to eq "1111 111 111"
      expect(res.first.params[:id]).to eq 101
    end

    it "returns empty array" do
      res = described_class.find_all([105, 104])
      expect(res).to be_a(Array)
      expect(res).to be_empty
    end
  end

  describe "#save" do
    before { contact_create_stub(Amorail.config.api_endpoint) }

    it "set id after create" do
      contact.save!
      expect(contact.id).to eq 101
    end
  end

  describe "#update" do
    before { contact_create_stub(Amorail.config.api_endpoint) }

    it "update params" do
      contact.save!
      contact.name = "foo"

      contact_update_stub(Amorail.config.api_endpoint)
      expect(contact.save!).to be_truthy
      expect(contact.name).to eq "foo"
    end

    it "raise error if id is blank?" do
      obj = described_class.new
      expect { obj.update!(name: 'Igor') }
        .to raise_error(Amorail::Entity::NotPersisted)
    end

    it "raise error" do
      obj = described_class.new
      expect { obj.update!(id: 101, name: "Igor") }
        .to(raise_error(Amorail::Entity::NotPersisted))
    end
  end
end
