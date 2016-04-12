class Vocabulary < Term
  configure :type => RDF::URI("http://purl.org/dc/dcam/VocabularyEncodingScheme")
  property :title, :predicate => RDF::DC.title
  property :publisher, :predicate => RDF::DC.publisher

  def self.option_text
    "Vocabulary"
  end

  def self.uri
    self.type.to_s
  end

  def self.visible_form_fields
    %w[label alternate_name date comment is_replaced_by is_defined_by same_as modified issued title publisher]
  end

  # Update the fields method with any new properties added to this model
  def fields
    [:title, :publisher] | super
  end
end
