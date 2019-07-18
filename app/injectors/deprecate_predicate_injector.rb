# frozen_string_literal: true

# Deprecate Predicate Injector
class DeprecatePredicateInjector < Struct.new(:params)
  delegate :vocabulary_repository, :child_node_finder, to: :vocabulary_injector

  def deprecate_predicate_form_repository
    DeprecatePredicateFormRepository.new(decorators)
  end

  def deprecate_predicate_repository
    StandardRepository.new(decorators, Predicate)
  end

  def params
    super || {}
  end

  private

  def decorators
    vocabulary_injector.decorators
  end

  def vocabulary_injector
    @vocabulary_injector ||= VocabularyInjector.new(params)
  end
end
