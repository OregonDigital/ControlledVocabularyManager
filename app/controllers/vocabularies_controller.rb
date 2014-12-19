class VocabulariesController < ApplicationController

  def new
    @vocabulary = Vocabulary.new
  end

  def create
    VocabularyCreator.call(params[:vocabulary], CreateResponder.new(self))
  end

  class CreateResponder < SimpleDelegator
    def success(vocabulary)
      redirect_to controlled_vocabulary_path(vocabulary)
    end

    def failure(vocabulary)
      __getobj__.instance_variable_set(:@vocabulary, vocabulary)
      render :new
    end
  end

end
