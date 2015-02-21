class VocabulariesController
  class CreateResponder < SimpleDelegator
    def success(vocabulary)
      redirect_to term_path(vocabulary)
    end

    def failure(vocabulary)
      __getobj__.instance_variable_set(:@vocabulary, vocabulary)
      render :new
    end
  end
end
