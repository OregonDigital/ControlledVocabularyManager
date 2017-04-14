# Repository that returns a decorated Term object with DeprecatePredicateForm
# validations.
class DeprecateRelationshipFormRepository < Struct.new(:decorators, :repository_type)
  delegate :new, :find, :exists?, :to => :repository

  def repository
    DecoratingRepository.new(decorators, Relationship)
  end

  private

  def decorators
    result = super || NullDecorator.new
    DecoratorList.new(result, term_form_decorator)
  end

  def term_form_decorator
    DecoratorWithArguments.new(DeprecateRelationshipForm, StandardRepository.new(nil, Relationship))
  end
end
