Rails.application.config.to_prepare do
  ActiveTriples::Repositories.add_repository :default, RDF::Marmotta.new(Settings.marmotta.url)
end
