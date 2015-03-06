class Term < ActiveTriples::Resource
  include ActiveTriplesAdapter
  configure :repository => :default
  configure :base_uri => "http://#{Rails.application.routes.default_url_options[:host]}/ns/"
  property :label, :predicate => RDF::RDFS.label
  property :comment, :predicate => RDF::RDFS.comment
  property :issued, :predicate => RDF::DC.issued
  property :modified, :predicate => RDF::DC.modified

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

  def editable_fields
    fields - [:issued, :modified]
  end

  def to_param
    id
  end

  private

  def not_blank_node
    errors.add(:id, "can not be blank") if node?
  end

end
