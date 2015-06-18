class Term < ActiveTriples::Resource
  include ActiveTriplesAdapter
  include ActiveModel::Validations
  configure :base_uri => "http://#{Rails.application.routes.default_url_options[:host]}/ns/"
  configure :repository => :default
  property :label, :predicate => RDF::RDFS.label
  property :comment, :predicate => RDF::RDFS.comment
  property :issued, :predicate => RDF::DC.issued
  property :modified, :predicate => RDF::DC.modified
  delegate :vocabulary_id, :leaf, :to => :term_uri, :prefix => true

  validate :not_blank_node

  def id
    return nil if rdf_subject.node?
    rdf_subject.to_s.gsub(self.class.base_uri,"")
  end

  def vocabulary?
    type.include?(*Array(Vocabulary.type))
  end

  def repository
    super
  end

  def editable_fields
    fields - [:issued, :modified]
  end

  def to_param
    id
  end

  def term_uri
    TermUri.new(rdf_subject)
  end

  def repository
    @repository ||= MarmottaRepository.new(rdf_subject, marmotta_connection)
  end

  private

  def marmotta_connection
    Marmotta::Connection.new(uri: Settings.marmotta.url, context: Rails.env)
  end

  def not_blank_node
    errors.add(:id, "can not be blank") if node?
  end

end
