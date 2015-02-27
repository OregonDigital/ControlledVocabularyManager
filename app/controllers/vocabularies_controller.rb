class VocabulariesController < ApplicationController
  before_filter :load_vocab, :only => :show
  skip_before_filter :check_auth, :only => [:index]

  def index
    @vocabularies = AllVocabsQuery.call(sparql_client)
  end

  def new
    @vocabulary = VocabularyForm.new(Vocabulary, vocab_params)
  end

  def create
    form = VocabularyForm.new(Vocabulary, vocab_params)
    if form.save
      redirect_to term_path(:id => form.term_id)
    else
      @vocabulary = form
      render "new"
    end
  end

  private

  def vocab_params
    ParamCleaner.call(params[:vocabulary] || {})
  end

  def sparql_client
    Vocabulary.new.repository.query_client
  end
end
