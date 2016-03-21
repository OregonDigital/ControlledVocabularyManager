class TermInjector < Struct.new(:params)
  delegate :vocabulary_repository, :child_node_finder, :to => :vocabulary_injector

  def term_form_repository
    TermFormRepository.new(decorators)
  end

  def term_repository
    StandardRepository.new(decorators, nil)
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
