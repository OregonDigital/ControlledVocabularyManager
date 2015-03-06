class VocabularyInjector < Struct.new(:params)
  def vocabulary_form
    @vocabulary_form ||= vocabulary_form_factory.new(built_vocabulary, vocabulary_repository)
  end

  def edit_vocabulary_form
    @edit_vocabulary_form ||= vocabulary_form_factory.new(found_vocabulary, vocabulary_repository)
  end

  def vocabulary_repository
    TermFactory.new(decorators)
  end

  def all_vocabs_query
    -> { AllVocabsQuery.call(sparql_client) }
  end
  
  def sparql_client
    @sparql_client ||= ActiveTriples::Repositories.repositories[Vocabulary.repository].query_client
  end

  def child_node_finder
    @child_node_finder ||= ChildNodeFinder.new(PolymorphicTermRepository, sparql_client)
  end

  def params
    super || {}
  end

  private

  def built_vocabulary
    vocabulary = vocabulary_repository.new(inner_vocabulary_params[:id])
    vocabulary.attributes = vocabulary_params.except(:id)
    vocabulary
  end

  def found_vocabulary
    vocab = vocabulary_repository.find(params[:id])
    vocab.attributes = vocabulary_params
    vocab
  end

  def decorators
    DecoratorList.new(
      SetsModified,
      SetsIssued,
      DecoratorWithArguments.new(TermWithChildren, child_node_finder)
    )
  end


  def vocabulary_form_factory
    VocabularyForm
  end

  def vocabulary_params
    ParamCleaner.call(inner_vocabulary_params)
  end

  def inner_vocabulary_params
    params[:vocabulary] || {}
  end
end
