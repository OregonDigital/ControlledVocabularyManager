class VocabularyInjector < Struct.new(:params)
  def vocabulary_form_repository
    VocabularyFormRepository.new(decorators)
  end

  def vocabulary_repository
    @vocabulary_repository ||= StandardRepository.new(decorators, nil)
  end

  def all_vocabs_query
     sparql = sparql_client.select.graph("#{Settings.marmotta.url}/context/#{Rails.env}")
    -> { AllVocabsQuery.call(sparql, vocabulary_repository, Vocabulary.type) }
  end
  
  def sparql_client
    @sparql_client ||= SPARQL::Client.new("#{Settings.marmotta.url}/sparql/select")
  end

  def child_node_finder
    sparql = sparql_client.select.graph("#{Settings.marmotta.url}/context/#{Rails.env}")
    @child_node_finder ||= ChildNodeFinder.new(StandardRepository.new, sparql)
  end

  def params
    super || {}
  end

  def decorators
    DecoratorList.new(
      SetsAttributes,
      SetsModified,
      SetsIssued,
      DecoratorWithArguments.new(TermWithChildren, child_node_finder)
    )
  end

end
