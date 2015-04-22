require 'amorail'

namespace :amorail do
  desc "Check Amorail configuration."
  task :check do
    p Amorail.properties.inspect
  end
end
