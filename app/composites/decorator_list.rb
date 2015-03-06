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
