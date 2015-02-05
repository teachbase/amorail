require 'amorail'
require 'rails'

module Amorail
  class Engine < Rails::Engine
    rake_tasks do
      load File.expand_path("../../tasks/amorail.rake", __FILE__)
    end
  end
end

