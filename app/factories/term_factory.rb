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
      decorators.inject(yield) do |term, decorator|
        decorator.new(term)
      end
    end

    def decorators
      [
        SetsModified,
        SetsIssued,
        TermWithChildren
      ]
    end

    def repository
      PolymorphicTermRepository
    end
  end
end

