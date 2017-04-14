class RelationshipInjector < Struct.new(:params)

  def relationship_form_repository
    RelationshipFormRepository.new(decorators)
  end

  def relationship_repository
    @relationship_repository ||= StandardRepository.new(decorators, Relationship)
  end

  def all_relationships_query
    -> { AllVocabsQuery.call(sparql_client, relationship_repository, Relationship.type) }
  end

  def sparql_client
    @sparql_client ||= SPARQL::Client.new("#{Settings.triplestore_adapter.url}")
  end

  def params
    super || {}
  end

  def decorators
    DecoratorList.new(
      SetsAttributes,
      SetsModified,
      SetsIssued,
      SetsTermType,
      AddResource,
      DecoratorWithArguments.new(TermWithoutChildren)
    )
  end
end
