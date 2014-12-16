def stub_repository
  allow(ActiveTriples::Repositories).to receive(:repositories).and_return({:default => RDF::Repository.new})
end
