class Term < ActiveTriples::Resource
  include ActiveTriplesAdapter
  configure :repository => :default
  configure :base_uri => "http://#{Rails.application.routes.default_url_options[:host]}/ns/"
  property :comment, :predicate => RDF::RDFS.comment
  property :modified, :predicate => RDF::DC.modified
  property :label, :predicate => RDF::RDFS.label
  property :issued, :predicate => RDF::DC.issued
  before_persist :set_issued, :if => :new_record?
  before_persist :set_modified, :if => :valid?

  validate :not_blank_node

  def id
    return nil if rdf_subject.node?
    rdf_subject.to_s.gsub(self.class.base_uri,"")
  end

  def vocabulary?
    type.include?(Vocabulary.type)
  end

  def repository
    super
  end

  private

  def not_blank_node
    errors.add(:id, "can not be blank") if node?
  end

  def set_issued
    self.issued = RDF::Literal::Date.new(Time.now)
  end

  def set_modified
    self.modified = RDF::Literal::Date.new(Time.now)
  end
end
