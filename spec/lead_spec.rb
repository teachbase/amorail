require "spec_helper"

describe Amorail::AmoLead do
  before { mock_api }

  describe "validations" do
    it { should validate_presence_of(:name)}
    it { should validate_presence_of(:status_id)}
  end
end