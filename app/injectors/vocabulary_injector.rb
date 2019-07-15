# frozen_string_literal: true

# Vocabulary Injector
class VocabularyInjector < Struct.new(:params)
  def vocabulary_form_repository
    VocabularyFormRepository.new(decorators)
  end

  def vocabulary_repository
    @vocabulary_repository ||= StandardRepository.new(decorators, Vocabulary)
  end

  def all_vocabs_query
    # Creating this SPARQL query before it goes in an actually builds the query
    # causes some issues with the objects and predicates being fetched properly
    # By inputing the sparql_client directly into the all vocabs query correctly
    # assembles the query.
    -> { AllVocabsQuery.call(sparql_client, vocabulary_repository, Vocabulary.type) }
  end

  def sparql_client
    @sparql_client ||= SPARQL::Client.new(Settings.triplestore_adapter.url)
  end

  def child_node_finder
    # See All Vocabs Query
    @child_node_finder ||= ChildNodeFinder.new(sparql_client)
  end

  def params
    super || {}
  end

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
end
