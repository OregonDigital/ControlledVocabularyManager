require 'warden/github/rails/test_helpers'
RSpec.configure do |config|
  config.include Warden::GitHub::Rails::TestHelpers
end
