require "spec_helper"

describe Amorail::Task do
  before { mock_api }

  describe "validations" do
    it { should validate_presence_of(:element_id) }
    it { should validate_presence_of(:element_type) }
    it { should validate_inclusion_of(:element_type).in_range(1..2) }
    it { should validate_presence_of(:text) }
    it { should validate_presence_of(:task_type) }
    it { should validate_presence_of(:complete_till) }
  end

  describe ".attributes" do
    subject { described_class.attributes }

    it_behaves_like 'entity_class'

    specify do
      is_expected.to include(
        :element_type,
        :element_id,
        :text,
        :task_type,
        :complete_till
      )
    end
  end

  describe "contact and lead" do
    let(:task) { described_class.new }
    it "set element_type on initialize" do
      expect(described_class.new(lead: true).element_type).to eq 2
      expect(described_class.new(contact: true).contact?).to be_truthy
      expect(described_class.new(lead: false).element_type).to be_nil
    end

    it "set element_type with bang method" do
      task.contact!
      expect(task.element_type).to eq 1
      task.lead!
      expect(task.element_type).to eq 2
    end
  end

  describe "#params" do
    let(:task) do
      described_class.new(
        element_id: 1,
        element_type: 1,
        text: 'Win the war',
        task_type: 'test',
        complete_till: '2015-05-09 12:00:00'
      )
    end

    subject { task.params }

    specify { is_expected.to include(:last_modified) }
    specify { is_expected.to include(element_id: 1) }
    specify { is_expected.to include(element_type: 1) }
    specify { is_expected.to include(text: 'Win the war') }
    specify { is_expected.to include(task_type: 'test') }
    specify {
      is_expected.to include(
        complete_till: Time.local(2015, 5, 9, 12, 0, 0).to_i
      )
    }
  end
end
