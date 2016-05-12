class Predicate < Term
  configure :type => RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate")
  property :sub_property_of, :predicate => RDF::RDFS.subPropertyOf
  property :range, :predicate => RDF::RDFS.range

end
