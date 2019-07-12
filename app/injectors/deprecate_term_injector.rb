# frozen_string_literal: true

class DeprecateTermInjector < Struct.new(:params)
  delegate :vocabulary_repository, :child_node_finder, to: :vocabulary_injector

  def deprecate_term_form_repository
    DeprecateTermFormRepository.new(decorators, Term)
  end

  def deprecate_term_repository
    StandardRepository.new(decorators, Term)
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
