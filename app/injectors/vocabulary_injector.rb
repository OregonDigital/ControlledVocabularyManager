class VocabularyInjector < Struct.new(:params)
  def vocabulary_form_repository
    VocabularyFormRepository.new(decorators)
  end

  def vocabulary_repository
    @vocabulary_repository ||= StandardRepository.new(decorators)
  end

  def all_vocabs_query
    -> { AllVocabsQuery.call(sparql_client, vocabulary_repository) }
  end
  
  def sparql_client
    @sparql_client ||= ActiveTriples::Repositories.repositories[Vocabulary.repository].query_client
  end

  def child_node_finder
    @child_node_finder ||= ChildNodeFinder.new(StandardRepository.new, sparql_client)
  end

  def params
    super || {}
  end

  def decorators
    DecoratorList.new(
      SetsModified,
      SetsIssued,
      DecoratorWithArguments.new(TermWithChildren, child_node_finder)
    )
  end

end
