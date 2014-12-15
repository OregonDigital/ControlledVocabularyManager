MARMOTTA_REPO ||= RDF::Marmotta.new("http://localhost:8983/marmotta/")
RSpec.configure do |config|
  config.before do
    MARMOTTA_REPO.clear!
  end
end
