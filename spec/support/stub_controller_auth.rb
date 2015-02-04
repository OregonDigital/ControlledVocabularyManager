RSpec.configure do |config|
  config.before(:type => :controller) do
    stub(controller).authorize { true }
    stub(controller).authenticate { true }
  end
end
