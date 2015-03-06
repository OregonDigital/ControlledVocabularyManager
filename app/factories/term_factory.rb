class TermFactory
  class << self
    def new(*args)
      decorate do
        repository.new(*args)
      end
    end

    def find(*args)
      decorate do
        repository.find(*args)
      end
    end

    def exists?(*args)
      repository.exists?(*args)
    end

    private

    def decorate
      decorators.new(yield)
    end

    def decorators
      DecoratorList.new(
        SetsModified,
        SetsIssued,
        DecoratorWithArguments.new(TermWithChildren, ChildNodeFinder)
      )
    end

    def repository
      PolymorphicTermRepository
    end
  end

end

