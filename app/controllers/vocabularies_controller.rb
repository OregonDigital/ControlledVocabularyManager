class VocabulariesController < ApplicationController
  before_filter :load_vocab, :only => :show

  def index
  end

  def new
    @vocabulary = Vocabulary.new
  end

  def create
    VocabularyCreator.call(params[:vocabulary], CreateResponder.new(self))
  end
end
