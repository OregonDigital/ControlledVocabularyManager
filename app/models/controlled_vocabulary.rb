class ControlledVocabulary < ActiveTriples::Resource
  configure :repository => :default
  property :comment, :predicate => RDF::RDFS.comment
  property :modified, :predicate => RDF::DC.modified
  property :label, :predicate => RDF::RDFS.label
  property :issued, :predicate => RDF::DC.issued
  before_persist :set_issued, :if => :new_record?
  before_persist :set_modified, :if => :valid?

  private

  def set_issued
    self.issued = RDF::Literal::Date.new(Time.now)
  end

  def set_modified
    self.modified = RDF::Literal::Date.new(Time.now)
  end
end
