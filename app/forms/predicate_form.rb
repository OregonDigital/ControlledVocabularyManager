# frozen_string_literal: true

class PredicateForm < SimpleDelegator
  include ActiveModel::Validations
  validates_with *TermValidations

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

    persist!
  end
end
