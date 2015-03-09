def stub_repository
  repository = RDF::Repository.new
  repository.define_singleton_method(:query_client) do
    SPARQL::Client.new(repository)
  end
  allow(ActiveTriples::Repositories).to receive(:repositories).and_return({:default => repository})
end
