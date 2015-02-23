MARMOTTA_REPO ||= RDF::Marmotta.new("http://localhost:8983/marmotta/")
RSpec.configure do |config|
  config.before do
    # TODO: We NEED to fix this.
    while MARMOTTA_REPO.count > 0
      MARMOTTA_REPO.clear!
    end
  end
end
