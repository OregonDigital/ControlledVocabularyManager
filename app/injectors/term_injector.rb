class TermInjector < VocabularyInjector
  def term_form
    @term_form ||= term_form_factory.new(built_term, term_repository)
  end

  def edit_term_form
    @edit_term_form ||= term_form_factory.new(term, term_repository)
  end

  def term_repository
    TermFactory
  end

  def term
    @term ||= term_repository.find(params[:id])
    @term.attributes = term_params.except(:id, :vocabulary_id)
    @term
  end

  private

  def built_term
    term = term_repository.new(combined_id)
    term.attributes = term_params.except(:id, :vocabulary_id)
    term
  end

  def combined_id
    "#{inner_term_params[:vocabulary_id]}/#{inner_term_params[:id]}"
  end

  def term_form_factory
    TermForm
  end

  def inner_term_params
    (params[:term] || {}).merge({:vocabulary_id => params[:vocabulary_id]})
  end
end
