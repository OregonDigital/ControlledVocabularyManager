class VocabulariesController < ApplicationController
  before_filter :load_vocab, :only => :show
  before_filter :authorize, :only => [:new, :create]

  def index
    @vocabularies = AllVocabsQuery.call(sparql_client)
  end

  def new
    @vocabulary = Vocabulary.new
  end

  def create
    VocabularyCreator.call(params[:vocabulary], CreateResponder.new(self))
  end

  private

  def sparql_client
    Vocabulary.new.repository.query_client
  end
  def authorize
    if session[:authorized] != true
      session[:user_route] = request.env['PATH_INFO']
      redirect_to '/login'
    end
  end
end
