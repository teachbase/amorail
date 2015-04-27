require "spec_helper"

describe Amorail::Lead do
  before { mock_api }

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:status_id) }
  end

  describe ".attributes" do
    subject { described_class.attributes }

    it_behaves_like 'entity_class'

    specify do
      is_expected.to include(
        :name,
        :price,
        :status_id,
        :tags
      )
    end
  end

  describe "#params" do
    let(:lead) do
      described_class.new(
        name: 'Test',
        price: 100,
        status_id: 2,
        tags: 'test lead'
      )
    end

    subject { lead.params }

    specify { is_expected.to include(:last_modified) }
    specify { is_expected.to include(name: 'Test') }
    specify { is_expected.to include(price: 100) }
    specify { is_expected.to include(status_id: 2) }
    specify { is_expected.to include(tags: 'test lead') }
  end
end
