class Vocabulary < Term
  configure :type => RDF::URI("http://purl.org/dc/dcam/VocabularyEncodingScheme")
  property :title, :predicate => RDF::Vocab::DC.title
  property :publisher, :predicate => RDF::Vocab::DC.publisher
  property :sub_property_of, :predicate => RDF::RDFS.subPropertyOf
  property :range, :predicate => RDF::RDFS.range
  property :domain, :predicate => RDF::RDFS.domain

  searchable auto_index: false, auto_remove: false do
    text :id
    text :label
    text :title do
      title
    end
  end

  def self.option_text
    "Vocabulary"
  end

  def self.uri
    self.type.to_s
  end

  def self.visible_form_fields
    %w[label alternate_name date comment is_replaced_by see_also is_defined_by same_as modified issued title publisher sub_property_of range domain]
  end

  def self.includes(included_field)
    VocabularyInjector.new({"controller"=>"vocabularies", "action"=>"index"}).all_vocabs_query.call.sort_by! {|v| v.rdf_label.first.to_s.downcase }
  end

  def allow_vocab_deprecate?
    deprecated_children.length == vocab_with_children.length
  end

  # Update the fields method with any new properties added to this model
  def fields
    [:title, :publisher, :sub_property_of, :range, :domain] | super
  end

  private

  def deprecated_children
    vocab_with_children.select { |c| c.deprecated? }
  end

  def vocab_with_children
    injector = TermInjector.new
    vocab = TermWithChildren.new(self, injector.child_node_finder)
    vocab.children
  end

end
