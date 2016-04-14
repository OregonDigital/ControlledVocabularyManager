class Term < ActiveTriples::Resource
  include ActiveTriplesAdapter
  include ActiveModel::Validations

  configure :base_uri => "http://#{Rails.application.routes.default_url_options[:host]}/ns/"
  configure :repository => :default

  property :label, :predicate => RDF::RDFS.label
  property :alternate_name, :predicate => RDF::URI("http://schema.org/alternateName")
  property :date, :predicate => RDF::DC.date
  property :comment, :predicate => RDF::RDFS.comment
  property :is_replaced_by, :predicate => RDF::DC.isReplacedBy
  property :is_defined_by, :predicate => RDF::RDFS.isDefinedBy
  property :same_as, :predicate => RDF::OWL.sameAs
  property :modified, :predicate => RDF::DC.modified
  property :issued, :predicate => RDF::DC.issued

  delegate :vocabulary_id, :leaf, :to => :term_uri, :prefix => true

  validate :not_blank_node

  def self.option_text
    "Generic Term"
  end

  def self.uri
    ""
  end

  def self.visible_form_fields
    %w[label alternate_name date comment is_replaced_by is_defined_by same_as modified issued]
  end

  def default_language
    :en
  end

  def blacklisted_language_properties
    [
      :id,
      :issued,
      :modified,
      :is_replaced_by,
      :date,
      :same_as,
      :is_defined_by
    ]
  end

  def id
    return nil if rdf_subject.node?
    rdf_subject.to_s.gsub(self.class.base_uri,"")
  end

  def deprecated?
    !values_for_property(:is_replaced_by).empty?
  end

  def allow_deprecate?
    true
  end

  def vocabulary?
    type.include?(*Array(Vocabulary.type))
  end

  def predicate?
    type.include?(*Array(Predicate.type))
  end

  def repository
    super
  end

  def editable_fields
    fields - [:issued, :modified, :is_replaced_by]
  end

  def editable_fields_deprecate
    fields - [:issued, :modified, :label, :comment, :date, :is_defined_by, :same_as, :alternate_name]
  end

  def to_param
    id
  end

  def values_for_property(property_name)
    self.get_values(property_name.to_s)
  end

  def term_uri
    TermUri.new(rdf_subject)
  end

  def term_id
    TermID.new(id)
  end

  def repository
    @repository ||= MarmottaRepository.new(rdf_subject, marmotta_connection)
  end

  #Returns a multi-dimensional array with translated language for a given
  #property.
  def literal_language_list_for_property(property_name)
    self.get_values(property_name.to_s, :literal => true).map{ |literal| [literal, language_from_symbol(literal.language)]}
  end

  def language_from_symbol(language_symbol)
    translator.find_by_symbol(language_symbol)
  end

  def translator
    ControlledVocabManager::IsoLanguageTranslator
  end

  private

  def marmotta_connection
    Marmotta::Connection.new(uri: Settings.marmotta.url, context: Rails.env)
  end

  def not_blank_node
    errors.add(:id, "can not be blank") if node?
  end
end
