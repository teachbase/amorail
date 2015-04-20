require "spec_helper"

describe Amorail::AmoTask do
  before { mock_api }
  
  describe "validations" do
    it { should validate_presence_of(:element_id) }
    it { should validate_presence_of(:element_type) }
    it { should validate_inclusion_of(:element_type).in_range(1..2) }
    it { should validate_presence_of(:text) }
    it { should validate_presence_of(:task_type) }
    it { should validate_presence_of(:complete_till) }
  end

  describe "contact and lead" do
    let(:task) { Amorail::AmoTask.new }
    it "should set element_type on initialize" do
      expect(Amorail::AmoTask.new(lead: true).element_type).to eq 2
      expect(Amorail::AmoTask.new(contact: true).contact?).to be_truthy
      expect(Amorail::AmoTask.new(lead: false).element_type).to be_nil
    end

    it "should set element_type with bang method" do
      task.contact!
      expect(task.element_type).to eq 1
      task.lead!
      expect(task.element_type).to eq 2
    end
  end
end