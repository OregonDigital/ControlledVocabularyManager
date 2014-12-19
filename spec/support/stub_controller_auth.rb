RSpec.configure do |config|
  config.before(:type => :controller) do
    allow(controller).to receive(:authorize).and_return(true)
    allow(controller).to receive(:authenticate).and_return(true)
  end
end
