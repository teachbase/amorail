# frozen_string_literal: true

require 'spec_helper'

describe Amorail::Note do
  before { mock_api }

  it_behaves_like 'elementable'

  describe 'validations' do
    it { is_expected.to validate_presence_of(:text) }
    it { is_expected.to validate_presence_of(:note_type) }
    it { is_expected.to validate_inclusion_of(:element_type).in_range(1..4) }
  end

  describe '.attributes' do
    subject { described_class.attributes }

    it_behaves_like 'entity_class'

    specify do
      is_expected.to include(
        :text,
        :note_type
      )
    end
  end
end
