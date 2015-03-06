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
        DelayedDecorator.new(TermWithChildren, ChildNodeFinder)
      )
    end

    def repository
      PolymorphicTermRepository
    end
  end

  class DecoratorList
    attr_reader :decorators

    def initialize(*decorators)
      @decorators = decorators
    end

    def new(term)
      decorators.inject(term) do |obj, decorator|
        decorator.new(obj)
      end
    end
  end
  class DelayedDecorator
    attr_reader :decorator, :args
    def initialize(decorator, *args)
      @decorator = decorator
      @args = args
    end

    def new(object)
      decorator.new(object, *args)
    end
  end
end

