namespace :amorail do
  desc 'Check Amorail configuration'
  task :check do
    puts Amorail.properties.inspect
  end
end
