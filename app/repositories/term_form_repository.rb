# Repository that returns a decorated Term object with TermForm
# validations.
class TermFormRepository < Struct.new(:decorators)
  delegate :new, :find, :exists?, :to => :repository

  def repository
    DecoratingRepository.new(decorators, Term)
  end

  private

  def decorators
    result = super || NullDecorator.new
    binding.pry
    DecoratorList.new(result, term_form_decorator)
  end

  def term_form_decorator
    DecoratorWithArguments.new(TermForm, StandardRepository.new)
  end
end
