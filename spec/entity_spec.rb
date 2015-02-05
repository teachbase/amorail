require "spec_helper"

describe Amorail::AmoEntity do
  before { mock_api }
  describe "#normalize_params" do
    it "should remove nulls and empty arrays" do
      data = {
        request: {
          contacts: {
            add: [
              {
                name: "test",
                date_create: nil,
                last_modified: nil,
                request_id: 1,
                responsible_user_id: 2,
                company_name: nil,
                linked_leads_id: [nil],
                custom_fields: [
                  {
                    id: 1,
                    values: [{value: "tester"}]
                  },
                  {
                    id: 2,
                    values: [{value: nil, enum: "MOB"}]
                  },
                  {
                    id: 3,
                    values: [{value: "111", enum: "WORK"}]
                  }
                ]
              }
            ]
          }
        }
      }

      compact = Amorail::AmoEntity.new.normalize_params(data)

      expect(compact[:request][:contacts][:add].length).to eq 1

      item = compact[:request][:contacts][:add].first

      expect(item.keys).to include(:name, :request_id, :responsible_user_id, :custom_fields)
      expect(item.keys).not_to include(:date_create, :last_modified, :company_name, :linked_leads_id)

      fields = item[:custom_fields]
      expect(fields.length).to eq 2
    end
  end
end