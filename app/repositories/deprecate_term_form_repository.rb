# frozen_string_literal: true

# Repository that returns a decorated Term object with DeprecateTermForm
# validations.
class DeprecateTermFormRepository < Struct.new(:decorators, :repository_type)
  delegate :new, :find, :exists?, :to => :repository

  def initialize(decorators, klass)
    @klass = klass || Term
  end

  def repository
    DecoratingRepository.new(decorators, @klass)
  end

  private

  def decorators
    result = super || NullDecorator.new
    DecoratorList.new(result, term_form_decorator)
  end

  def term_form_decorator
    DecoratorWithArguments.new(DeprecateTermForm, StandardRepository.new(nil, @klass))
  end
end
