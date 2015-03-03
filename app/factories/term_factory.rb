class TermFactory
  class << self
    def new(*args)
      decorate do
        PolymorphicTermRepository.new(*args)
      end
    end

    def find(*args)
      decorate do
        PolymorphicTermRepository.find(*args)
      end
    end

    def exists?(*args)
      Term.exists?(*args)
    end

    private

    def decorate
      result = yield
      
      TermWithChildren.new(result)
    end
  end
end

