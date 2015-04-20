require "spec_helper"

describe Amorail::AmoEntity do
  before { mock_api }
  describe "#normalize_params and #to_timestamp" do
    it "should remove nulls and empty arrays" do
      _now = Time.now

      company = Amorail::AmoCompany.new(
        name: "test", 
        request_id: 1, 
        responsible_user_id: 2, 
        date_create: _now,
        last_modified: _now.to_date,
        address: "tester",
        phone: "111"
      )

      compact = Amorail::AmoEntity.new.normalize_params(company.create_params('add'))

      expect(compact[:request][:contacts][:add].length).to eq 1

      item = compact[:request][:contacts][:add].first

      expect(item.keys).to include(
        "name",
        "date_create",
        "last_modified",
        "request_id",
        "responsible_user_id",
        "custom_fields"
      )
      expect(item.keys).not_to include(:company_name, :linked_leads_id)

      expect(item[:date_create]).to eql _now.to_i
      expect(item[:last_modified]).to eql _now.to_date.to_time.to_i

      fields = item[:custom_fields]
      expect(fields.length).to eq 2
    end
  end
end