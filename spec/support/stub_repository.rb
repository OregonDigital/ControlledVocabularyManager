def stub_repository
  ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
end
