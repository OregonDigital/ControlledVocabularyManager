class TermFactory
  class << self
    def new(*args)
      decorate do
        Term.new(*args)
      end
    end

    def find(*args)
      decorate do
        Term.find(*args)
      end
    end

    private

    def decorate
      result = yield
      TermWithChildren.new(result)
    end
  end
end
