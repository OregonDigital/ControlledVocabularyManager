def stub_repository
  stub(ActiveTriples::Repositories).repositories do
    {
      :default => RDF::Repository.new
    }
  end
end
