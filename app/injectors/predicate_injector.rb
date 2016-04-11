class PredicateInjector < Struct.new(:params)

  def predicate_form_repository
    PredicateFormRepository.new(decorators)
  end

  def predicate_repository
    @predicate_repository ||= StandardRepository.new(decorators,nil)
  end

  def all_preds_query
    -> { AllVocabsQuery.call(sparql_client, predicate_repository, Predicate.type) }
  end

  def sparql_client
    @sparql_client ||= SPARQL::Client.new("#{Settings.triplestore_adapter.url}")
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

