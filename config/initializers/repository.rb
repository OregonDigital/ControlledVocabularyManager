Rails.application.config.to_prepare do
  ActiveTriples::Repositories.add_repository :default, RDF::Marmotta.new("http://localhost:8983/marmotta/")
end
