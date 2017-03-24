class RelationshipForm < SimpleDelegator
  include ActiveModel::Validations
  validates_with *(TermValidations)

  attr_reader :repository
  def initialize(relationship, repository)
    @repository = repository
    __setobj__(relationship)
  end

  def is_valid?
    valid?
  end

  def save
    return false unless valid?
    self.persist!
  end
end
