# frozen_string_literal: true

# Abstract Decorator that supports args
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
