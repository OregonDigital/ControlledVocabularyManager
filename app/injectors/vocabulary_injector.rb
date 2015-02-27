class VocabularyInjector < Struct.new(:params)
  def term_form
    @term_form ||= term_form_factory.new(term_repository, term_params)
  end

  def term_repository
    vocabulary_repository
  end

  def all_vocabs_query
    -> { AllVocabsQuery.call(sparql_client) }
  end

  def vocabulary_repository
    Vocabulary
  end

  private

  def sparql_client
    @sparql_client ||= term_repository.new.repository.query_client
  end


  def term_form_factory
    VocabularyForm
  end

  def term_params
    ParamCleaner.call(inner_term_params)
  end

  def inner_term_params
    params[:vocabulary] || {}
  end
end
