class VocabulariesController < ApplicationController

  def new
    @vocabulary = Vocabulary.new
  end

  def create
    creator = VocabularyCreator.call(params[:vocabulary])
    if creator.result
      redirect_to controlled_vocabulary_path(creator.vocabulary)
    else
      @vocabulary = creator.vocabulary
      render :new
    end
  end

end
