class DecoratorWithArguments
  attr_reader :decorator, :args
  def initialize(decorator, *args)
    @decorator = decorator
    @args = args
  end

  def new(object)
    decorator.new(object, *args)
  end
end
