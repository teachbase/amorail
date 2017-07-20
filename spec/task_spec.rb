require "spec_helper"

describe Amorail::Task do
  before { mock_api }

  it_behaves_like 'elementable'

  describe "validations" do
    it { should validate_presence_of(:text) }
    it { should validate_presence_of(:task_type) }
    it { should validate_presence_of(:complete_till) }
  end

  describe ".attributes" do
    subject { described_class.attributes }

    it_behaves_like 'entity_class'

    specify do
      is_expected.to include(
        :text,
        :task_type,
        :complete_till
      )
    end
  end

  describe "#params" do
    let(:task) do
      described_class.new(
        text: 'Win the war',
        task_type: 'test',
        complete_till: '2015-05-09 12:00:00'
      )
    end

    subject { task.params }

    specify { is_expected.to include(:last_modified) }
    specify { is_expected.to include(text: 'Win the war') }
    specify { is_expected.to include(task_type: 'test') }
    specify {
      is_expected.to include(
        complete_till: Time.local(2015, 5, 9, 12, 0, 0).to_i
      )
    }
  end
end
