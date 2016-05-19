class VocabularyInjector < Struct.new(:params)
  def vocabulary_form_repository
    VocabularyFormRepository.new(decorators)
  end

  def vocabulary_repository
    @vocabulary_repository ||= StandardRepository.new(decorators, nil)
  end

  def all_vocabs_query
    #Creating this SPARQL query before it goes in an actually builds the query
    #causes some issues with the objects and predicates being fetched properly
    #By inputing the sparql_client directly into the all vocabs query correctly
    #assembles the query.
    #sparql = sparql_client.select.graph("#{Settings.marmotta.url}/context/#{Rails.env}")
    -> { AllVocabsQuery.call(sparql_client, vocabulary_repository, Vocabulary.type) }
  end
  
  def sparql_client
    @sparql_client ||= SPARQL::Client.new("#{Settings.marmotta.url}/sparql/select")
  end

  def child_node_finder
    #See All Vocabs Query
    #sparql = sparql_client.select.graph("#{Settings.marmotta.url}/context/#{Rails.env}")
    @child_node_finder ||= ChildNodeFinder.new(StandardRepository.new, sparql_client)
  end

  def node_finder
    sparql = sparql_client.select.graph("#{Settings.marmotta.url}/context/#{Rails.env}")
    @node_finder ||= NodeFinder.new(StandardRepository.new, sparql)
  end

  def params
    super || {}
  end

  def decorators
    DecoratorList.new(
      SetsAttributes,
      SetsModified,
      SetsIssued,
      DecoratorWithArguments.new(TermWithChildren, child_node_finder),
      DecoratorWithArguments.new(TermWithoutChildren, node_finder)
    )
  end

end
