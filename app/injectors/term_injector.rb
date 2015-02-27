class TermInjector < VocabularyInjector
  def term_form
    @term_form ||= term_form_factory.new(term_repository, term_params)
  end

  def term_repository
    TermFactory
  end

  def term
    @term ||= term_repository.find(params[:id])
  end

  private

  def term_form_factory
    TermForm
  end

  def inner_term_params
    (params[:term] || {}).merge({:vocabulary_id => params[:vocabulary_id]})
  end
end
