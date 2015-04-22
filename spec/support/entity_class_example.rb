require 'spec_helper'

shared_examples 'entity_class' do
  subject { described_class.attributes }

  specify do
    is_expected.to include(
      :id,
      :request_id,
      :responsible_user_id,
      :date_create,
      :last_modified
    )
  end
end
