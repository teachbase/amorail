require 'amorail'
require 'rails'

module Amorail
  class Engine < Rails::Engine
    rake_tasks do
      load "tasks/tasks.rake"
    end
  end
end

