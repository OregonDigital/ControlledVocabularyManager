class VocabulariesController < ApplicationController

  def new
    @vocabulary = Vocabulary.new
  end

end
