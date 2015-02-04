class VocabulariesController < ApplicationController
  attr_writer :vocabulary
  before_filter :load_vocab, :only => :show

  def index

  end

  def new
    @vocabulary = Vocabulary.new
  end

  def create
    VocabularyCreator.call(params[:vocabulary], CreateResponder.new(self))
  end

  class CreateResponder < SimpleDelegator
    def success(vocabulary)
      redirect_to term_path(vocabulary)
    end

    def failure(vocabulary)
      self.vocabulary = vocabulary
      render :new
    end
  end
end
