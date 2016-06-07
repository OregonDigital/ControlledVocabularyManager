# build the namespace if it doesn't already exist. Test needs to manage this
# itself so that WebMock allows for the HTTP calls, and Production is sensitive
# and shouldn't be automatically built.
unless Rails.env.downcase == 'test' || Rails.env.downcase == 'production'
  repository = TriplestoreRepository.new(nil, 'blazegraph', Settings.triplestore_adapter.url)
  repository.triplestore.client.provider.build_namespace(Rails.env.downcase)
end

