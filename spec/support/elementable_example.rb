# frozen_string_literal: true

shared_examples 'elementable' do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:element_id) }
    it { is_expected.to validate_presence_of(:element_type) }
  end

  describe '.attributes' do
    subject { described_class.attributes }

    specify do
      is_expected.to include(
        :element_type,
        :element_id
      )
    end
  end

  describe '#params' do
    subject { elementable.params }

    let(:elementable) do
      described_class.new(
        element_id: 1,
        element_type: 2
      )
    end

    it { is_expected.to include(element_id: 1) }
    it { is_expected.to include(element_type: 2) }
  end

  describe 'element type behaviour' do
    let(:elementable) { described_class.new }

    it 'set element_type on initialize' do
      expect(described_class.new(lead: true).element_type).to eq 2
      expect(described_class.new(lead: false).element_type).to be_nil
      expect(described_class.new(contact: true).contact?).to be_truthy
    end

    it 'set element_type with bang method' do
      elementable.contact!
      expect(elementable.element_type).to eq 1

      elementable.lead!
      expect(elementable.element_type).to eq 2

      elementable.company!
      expect(elementable.element_type).to eq 3
    end
  end
end
