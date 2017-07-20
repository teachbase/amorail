require 'spec_helper'

describe Amorail::Note do
  before { mock_api }

  it_behaves_like 'elementable'

  describe 'validations' do
    it { is_expected.to validate_presence_of(:note_type) }
    it { is_expected.to validate_presence_of(:text) }
  end

  describe '.attributes' do
    subject { described_class.attributes }

    it_behaves_like 'entity_class'

    specify do
      is_expected.to include(
        :note_type,
        :text
      )
    end
  end
end
