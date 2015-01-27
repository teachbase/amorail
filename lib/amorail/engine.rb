require 'amorail'
require 'rails'

module Amorail
  class Engine < Rails::Engine
    rake_tasks do
      load "amorail/tasks/class_generator.rake"
    end
  end
end

