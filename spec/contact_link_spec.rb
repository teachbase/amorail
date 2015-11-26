require "spec_helper"

describe Amorail::ContactLink do
  before { mock_api }

  describe ".attributes" do
    subject { described_class.attributes }

    it_behaves_like 'entity_class'

    specify do
      is_expected.to include(
        :contact_id,
        :lead_id
      )
    end
  end

  describe ".find_by_leads" do
    before { leads_links_stub(Amorail.config.api_endpoint, [2]) }

    it "returns list of contact links" do
      res = described_class.find_by_leads(2)
      expect(res.size).to eq 2
      expect(res.first.contact_id).to eq "101"
      expect(res.last.contact_id).to eq "102"
    end
  end

  describe ".find_by_contacts" do
    before { contacts_links_stub(Amorail.config.api_endpoint, [101]) }

    it "returns list of contact links" do
      res = described_class.find_by_contacts(101)
      expect(res.size).to eq 2
      expect(res.first.lead_id).to eq "1"
      expect(res.last.lead_id).to eq "2"
    end
  end
end
