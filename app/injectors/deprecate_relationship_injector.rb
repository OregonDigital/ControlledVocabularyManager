class DeprecateRelationshipInjector < Struct.new(:params)
  delegate :vocabulary_repository, :child_node_finder, :to => :vocabulary_injector

  def deprecate_relationship_form_repository
    DeprecateRelationshipFormRepository.new(decorators)
  end

  def deprecate_relationship_repository
    StandardRepository.new(decorators, Relationship)
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
