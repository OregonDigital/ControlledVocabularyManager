# frozen_string_literal: true

class TermInjector < Struct.new(:params)
  delegate :vocabulary_repository, :child_node_finder, to: :vocabulary_injector

  def term_form_repository
    TermFormRepository.new(@klass)
  end

  def term_repository
    StandardRepository.new(decorators, @klass)
  end

  def params
    super || {}
  end

  private

  def decorators
    DecoratorList.new(
      SetsTermType,
      SetsAttributes,
      SetsModified,
      SetsIssued,
      AddResource,
      DecoratorWithArguments.new(TermWithChildren, child_node_finder),
      DecoratorWithArguments.new(TermWithoutChildren)
    )
  end

  def vocabulary_injector
    @vocabulary_injector ||= VocabularyInjector.new(params)
  end
end
