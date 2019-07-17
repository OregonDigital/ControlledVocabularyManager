# frozen_string_literal: true

# Repository that returns a decorated Vocabulary object with VocabularyForm
# validations.
class PredicateFormRepository < Struct.new(:decorators)
  delegate :new, :find, :exists?, to: :repository

  def repository
    DecoratingRepository.new(decorators, Predicate)
  end

  private

  def decorators
    result = super || NullDecorator.new
    DecoratorList.new(result, term_form_decorator)
  end

  def term_form_decorator
    DecoratorWithArguments.new(PredicateForm, StandardRepository.new(nil, Predicate))
  end
end
