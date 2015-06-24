require "spec_helper"

describe MyEntity do
  before { mock_api }

  let(:entity) { described_class.new }

  it_behaves_like 'entity_class'

  describe "#params" do
    let(:now) { Time.now }

    subject { entity.params }

    specify { is_expected.to include(:last_modified) }
    specify {
      is_expected.not_to include(
        :id, :request_id, :responsible_user_id, :date_create)
    }

    context "with some values" do
      let(:entity) do
        described_class.new(
          responsible_user_id: 2,
          last_modified: now
        )
      end

      specify { is_expected.to include(responsible_user_id: 2) }
      specify { is_expected.to include(last_modified: now.to_i) }
      specify {
        is_expected.not_to include(
          :id, :request_id, :date_create)
      }
    end

    context "with all values" do
      let(:entity) do
        described_class.new(
          id: 100,
          request_id: 1,
          responsible_user_id: 2,
          date_create: now,
          last_modified: now
        )
      end

      specify { is_expected.to include(id: 100) }
      specify { is_expected.to include(request_id: 1) }
      specify { is_expected.to include(responsible_user_id: 2) }
      specify { is_expected.to include(date_create: now.to_i) }
      specify { is_expected.to include(last_modified: now.to_i) }
    end
  end
end
