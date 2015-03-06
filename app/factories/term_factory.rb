class TermFactory
  attr_reader :decorators

  def initialize(decorators)
    @decorators = decorators
  end

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

  def repository
    PolymorphicTermRepository
  end

end

