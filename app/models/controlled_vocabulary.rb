class ControlledVocabulary < ActiveTriples::Resource
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

  private

  def not_blank_node
    errors.add(:rdf_subject, "can not be a blank node") if node?
  end

  def set_issued
    self.issued = RDF::Literal::Date.new(Time.now)
  end

  def set_modified
    self.modified = RDF::Literal::Date.new(Time.now)
  end
end
