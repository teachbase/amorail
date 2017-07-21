module Amorail
  # Add amorail rake tasks
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path('../../tasks/amorail.rake', __FILE__)
    end
  end
end
