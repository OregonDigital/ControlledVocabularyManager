RSpec.configure do |c|
  c.include Warden::Test::ControllerHelpers, type: :controller
end
