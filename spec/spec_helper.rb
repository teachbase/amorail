$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'amorail'
require 'pry-byebug'
require 'webmock/rspec'
require 'shoulda/matchers'
require 'helpers/webmock_helpers'

# Cleanup Amorail env
ENV.delete_if { |k, _| k =~ /amorail/i }
ENV["AMORAIL_CONF"] = File.expand_path("fixtures/amorail_test.yml", __dir__)

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  include AmoWebMock
end
