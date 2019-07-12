# frozen_string_literal: true

class DeprecateTermForm < SimpleDelegator
  include ActiveModel::Validations
  validates_with VocabularyExists
  validates_with IsValidIsReplacedBy

  attr_reader :repository
  def initialize(term, repository)
    @repository = repository
    __setobj__(term)
  end

  def is_valid?
    valid?
  end

  def save
    return false unless valid?
    self.persist!
  end

end
