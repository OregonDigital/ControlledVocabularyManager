# frozen_string_literal: true

# Repository that returns a decorated Term object with DeprecatePredicateForm
# validations.
class DeprecatePredicateFormRepository < Struct.new(:decorators, :repository_type)
  delegate :new, :find, :exists?, :to => :repository

  def repository
    DecoratingRepository.new(decorators, Predicate)
  end

  private

  def decorators
    result = super || NullDecorator.new
    DecoratorList.new(result, term_form_decorator)
  end

  def term_form_decorator
    DecoratorWithArguments.new(DeprecatePredicateForm, StandardRepository.new(nil, Predicate))
  end
end
