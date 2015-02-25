class Vocabulary < Term
  configure :type => RDF::URI("http://purl.org/dc/dcam/VocabularyEncodingScheme")
  property :title, :predicate => RDF::DC.title
  property :publisher, :predicate => RDF::DC.publisher
end
