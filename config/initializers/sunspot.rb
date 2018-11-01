unless Rails.env.test?
  config = YAML.safe_load(ERB.new(IO.read(Rails.root + 'config' + 'sunspot.yml')).result)[Rails.env].with_indifferent_access
  Sunspot.config.solr.url = config['solr']['hostname']
  Sunspot.config.pagination.default_per_page = config['solr']['pagination_default_per_page'] || 30
  Sunspot.config.indexing.default_batch_size = config['solr']['index_default_batch_size'] || 30
end
