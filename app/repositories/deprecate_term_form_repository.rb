# Repository that returns a decorated Term object with DeprecateTermForm
# validations.
class DeprecateTermFormRepository < Struct.new(:decorators, :repository_type)
  delegate :new, :find, :exists?, :to => :repository

  def repository
    DecoratingRepository.new(decorators, Term)
  end

  private

  def decorators
    result = super || NullDecorator.new
    DecoratorList.new(result, term_form_decorator)
  end

  def term_form_decorator
    DecoratorWithArguments.new(DeprecateTermForm, StandardRepository.new(nil, Term))
  end
end
