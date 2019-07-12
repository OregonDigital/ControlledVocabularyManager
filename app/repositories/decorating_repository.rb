# frozen_string_literal: true

class DecoratingRepository
  attr_reader :decorators, :repository

  def initialize(decorators, repository)
    @decorators = decorators
    @repository = repository
  end

  def new(*args)
    decorate do
      if args[1].blank?
        repository.new(*args)
      else
        args[1].new(*args)
      end
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

end

