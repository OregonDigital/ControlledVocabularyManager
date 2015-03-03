class VocabularyInjector < Struct.new(:params)
  def vocabulary_form
    @vocabulary_form ||= vocabulary_form_factory.new(built_vocabulary, vocabulary_repository)
  end

  def vocabulary_repository
    Vocabulary
  end

  def all_vocabs_query
    -> { AllVocabsQuery.call(sparql_client) }
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

  def sparql_client
    @sparql_client ||= vocabulary_repository.new.repository.query_client
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
