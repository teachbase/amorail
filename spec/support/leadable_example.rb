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

  describe "#leads" do
    before { leads_stub(Amorail.config.api_endpoint, [1, 2]) }

    let(:leadable) { described_class.new(linked_leads_id: ['1', '2']) }

    it "loads leads" do
      expect(leadable.leads.size).to eq 2
      expect(leadable.leads.first).to be_a(Amorail::Lead)
      expect(leadable.leads.first.name).to eq "Research new technologies"
    end

    it "cache results" do
      url = URI.join(Amorail.config.api_endpoint, Amorail::Lead.remote_url('list'))
      leadable.leads
      leadable.leads
      expect(WebMock).to have_requested(:get, url).with(query: { id: [1, 2] }).once
    end
  end
end
