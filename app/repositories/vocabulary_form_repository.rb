# Repository that returns a decorated Vocabulary object with VocabularyForm
# validations.
class VocabularyFormRepository < Struct.new(:decorators)
  delegate :new, :find, :exists?, :to => :repository

  def repository
    DecoratingRepository.new(decorators, Vocabulary)
  end

  private

  def decorators
    result = super || NullDecorator.new
    DecoratorList.new(result, term_form_decorator)
  end

  def term_form_decorator
    DecoratorWithArguments.new(VocabularyForm, StandardRepository.new)
  end
end
