class TermsController
  class CreateResponder < SimpleDelegator
    def success(term, _)
      redirect_to term_path(term)
    end

    def failure(term, vocabulary)
      __getobj__.instance_variable_set(:@term, term)
      __getobj__.instance_variable_set(:@vocabulary, vocabulary)
      render "new"
    end
  end
end
