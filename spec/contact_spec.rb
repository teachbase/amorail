require "spec_helper"

describe Amorail::AmoContact do
  before { mock_api }
  
  describe "validations" do
    it { should validate_presence_of(:name)}
  end
end