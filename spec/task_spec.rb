require "spec_helper"

describe Amorail::AmoTask do
  before { mock_api }
  
  describe "validations" do
    it { should validate_presence_of(:element_id)}
    it { should validate_presence_of(:element_type)}
    it { should validate_inclusion_of(:element_type).in_range(1..2)}
    it { should validate_presence_of(:text)}
    it { should validate_presence_of(:task_type)}
    it { should validate_presence_of(:complete_till)}
  end
end