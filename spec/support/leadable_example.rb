require 'spec_helper'

shared_examples 'leadable' do
  let(:leadable) { described_class.new }
  subject { leadable.params }

  specify { is_expected.not_to include(:linked_leads_id) }

  context 'with leads' do
    before { leadable.linked_leads_id << 100 }
    specify { is_expected.to include(:linked_leads_id) }
    specify { expect(subject.fetch(:linked_leads_id)).to include(100) }
  end
end
