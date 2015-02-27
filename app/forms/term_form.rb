class TermForm < SimpleDelegator
  include ActiveModel::Validations
  validate :vocabulary_exists

  attr_reader :repository
  def initialize(term, repository)
    @repository = repository
    __setobj__(term)
  end

  private

  def vocabulary_exists
    unless repository.exists?(vocabulary_id)
      errors.add(:id, "is in a non existent vocabulary")
    end
  end

  def vocabulary_id
    rdf_subject.parent.to_s.gsub(base_uri, '').gsub(/\/$/,'')
  end

end
