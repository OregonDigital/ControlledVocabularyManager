class ControlledVocabulary < ActiveTriples::Resource
  configure :repository => :default
  property :comment, :predicate => RDF::RDFS.comment
  property :modified, :predicate => RDF::DC.modified
  property :label, :predicate => RDF::RDFS.label
  property :issued, :predicate => RDF::DC.issued
end
