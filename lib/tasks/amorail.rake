require 'amorail'

namespace :amorail do
  desc "Check Amorails configuration. Authorize and get custom fields information"
  task :check do
    p Amorail.properties
  end
end