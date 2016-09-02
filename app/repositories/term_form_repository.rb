# Repository that returns a decorated Term object with TermForm
# validations.
class TermFormRepository < Struct.new(:decorators, :repository_type)
  delegate :new, :find, :exists?, :to => :repository

  def initialize(klass)
    @klass = klass || Term
  end

  def repository
    DecoratingRepository.new(decorators, @klass)
  end

  private

  def decorators
    DecoratorList.new(
      SetsTermType,
      SetsAttributes,
      SetsModified,
      SetsIssued,
      AddResource,
      term_form_decorator
    )
  end

  def term_form_decorator
    DecoratorWithArguments.new(TermForm, StandardRepository.new(nil, @klass))
  end
end
