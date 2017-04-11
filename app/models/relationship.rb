class Relationship < Term 

  attr_accessor :commit_history

  configure :type => RDF::URI("http://vivoweb.org/ontology/core#Relationship")

  property :hier_parent, :predicate => RDF::Vocab::SKOS.broader
  property :hier_child, :predicate => RDF::Vocab::SKOS.narrower
  property :date, :predicate => RDF::Vocab::DC.date
  property :comment, :predicate => RDF::RDFS.comment

  # Update the fields method with any new properties added to this model
  def fields
    [:hier_parent, :hier_child, :date, :comment]
  end

  def self.option_text
    "Relationship"
  end

  def self.uri
    self.type.to_s
  end

  def self.visible_form_fields
    %w[hier_parent hier_child date comment]
  end

end
