# frozen_string_literal: true

# Term
class Term < ActiveTriples::Resource
  include ActiveTriplesAdapter
  include ActiveModel::Validations

  validates_with ValidUri

  attr_accessor :commit_history

  configure base_uri: "http://#{Rails.application.routes.default_url_options[:host]}/ns/"
  configure repository: :default
  configure type: RDF::URI('http://www.w3.org/2004/02/skos/core#Concept')

  property :label, predicate: RDF::RDFS.label
  property :alternate_name, predicate: RDF::URI('http://schema.org/alternateName')
  property :ark, predicate: RDF::URI('http://opaquenamespace.org/ns/ark')
  property :local, predicate: RDF::Vocab::Identifiers.local
  property :date, predicate: RDF::Vocab::DC.date
  property :comment, predicate: RDF::RDFS.comment
  property :is_replaced_by, predicate: RDF::Vocab::DC.isReplacedBy
  property :see_also, predicate: RDF::RDFS.seeAlso
  property :is_defined_by, predicate: RDF::RDFS.isDefinedBy
  property :same_as, predicate: RDF::OWL.sameAs
  property :modified, predicate: RDF::Vocab::DC.modified
  property :issued, predicate: RDF::Vocab::DC.issued

  delegate :vocabulary_id, :leaf, to: :term_uri, prefix: true

  validate :not_blank_node

  Sunspot::Adapters::InstanceAdapter.register(SunspotHelper::InstanceAdapter, Term)
  Sunspot::Adapters::DataAccessor.register(SunspotHelper::DataAccessor, Term)

  Sunspot.setup(Term) do
    text :id
    text :label, boost: 2.0
    text :comment, stored: true
    text :alternate_name, stored: true

    string :id, stored: true
    string :label, stored: true, multiple: true
    string :date, stored: true, multiple: true
  end

  def self.option_text
    'Concept'
  end

  def self.uri
    type.to_s
  end

  def self.visible_form_fields
    %w[label alternate_name date comment is_replaced_by see_also is_defined_by same_as modified issued]
  end

  def default_language
    :en
  end

  def blacklisted_language_properties
    %i[
      id
      issued
      modified
      see_also
      is_replaced_by
      date
      same_as
      is_defined_by
      range
      domain
      sub_property_of
      ark
      local
    ]
  end

  def uri_fields
    %i[
       see_also
       is_replaced_by
       same_as
       is_defined_by
       range
       domain
       sub_property_of
       ark
       local
    ]
  end

  def id
    return nil if rdf_subject.node?

    rdf_subject.to_s.gsub(self.class.base_uri, '')
  end

  ##
  # Is this term currently deprecated?
  #
  # @return [Boolean] true if this terms property :is_replaced_by has a value
  def deprecated?
    !values_for_property(:is_replaced_by).empty?
  end

  ##
  # Is this vocabulary currently deprecated?
  #
  # @return [Boolean] true if this vocabulary is deprecated
  def deprecated_vocab?
    Term.find(vocab_subject_uri).deprecated? if Term.exists?(vocab_subject_uri)
  end

  def vocabulary?
    term_type == Vocabulary
  end

  def predicate?
    term_type == Predicate
  end

  def editable_fields
    fields - %i[issued modified is_replaced_by]
  end

  def editable_fields_deprecate
    fields - %i[issued modified label comment date see_also is_defined_by same_as alternate_name ark local]
  end

  def to_param
    id
  end

  def values_for_property(property_name)
    get_values(property_name.to_s)
  end

  def term_uri
    TermUri.new(rdf_subject)
  end

  def term_id
    TermID.new(id)
  end

  def repository
    rdf_statement = RDF::Statement.new(subject: rdf_subject)
    @repository ||= TriplestoreRepository.new(rdf_statement, Settings.triplestore_adapter.type, Settings.triplestore_adapter.url)
  end

  ##
  # Returns a multi-dimensional array with translated language for a given property.
  #
  # @param property_name [Symbol] the property name to get language for
  def literal_language_list_for_property(property_name)
    get_values(property_name.to_s, literal: true).map do |literal|
      [literal, (literal.respond_to?(:language) ? language_from_symbol(literal.language) : language_from_symbol(0))]
    end
  end

  def language_from_symbol(language_symbol)
    translator.find_by_symbol(language_symbol)
  end

  def translator
    ControlledVocabManager::IsoLanguageTranslator
  end

  ##
  # The friendly text 'titleize'd, ie. "Personal Name"
  # @return [String] the term type
  def titleized_type
    term_type.option_text.titleize
  end

  ##
  # The friendly text 'parameterize'd, ie. "personalname"
  # @return [String] the term type
  def parameterized_type
    term_type.option_text.parameterize
  end

  ##
  # Get the full graph of this term, after its term type is updated so that the serialized details of the term do not
  # have unnecessary term types (Term base class) included
  #
  # @return [RDF::Graph] an RDF graph of this whole term
  def full_graph
    self.term_type = TermType.class_from_types(type)
    inject(RDF::Graph.new, :<<)
  end

  ##
  # Sort the graph statements and prepare for display, such as the git history of recent changes
  # @param graph [RDF::Graph] an RDF graph to sort
  # @return [Array<String>] a sorted array of statements
  def sort_stringify(graph)
    triples = graph.statements.to_a.sort_by(&:predicate).inject { |collector, element| collector.to_s + ' ' + element.to_s }
    "#{triples.to_s.gsub(' . ', " .\n")}\n"
  end

  ##
  # Update this instance of the terms type, see the getter and setter for details
  def set_term_type
    self.term_type = term_type
  end

  ##
  # Return the class of a term that best matches this instances set type. (type is an additive array in ActiveTriples
  # so each model which inherits from Term.rb includes its type, which is undesirable)
  #
  # @return [Class] the class of this instance of a term
  def term_type
    TermType.class_from_types(type)
  end

  ##
  # Remove the Term.type from this instances array unless this instance is actually a Term
  #
  # @param value [Class] this instances type
  def term_type=(type)
    self[:type] = self.type - [Term.type] unless type == Term
  end

  private

  def vocab_subject_uri
    term_uri.uri.to_s
  end

  def not_blank_node
    errors.add(:id, 'can not be blank') if node?
  end
end
