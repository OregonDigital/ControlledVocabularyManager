class StandardRepository < Struct.new(:decorators)
  delegate :find, :exists?, :new, :to => :repository
  def repository
    decorating_repository
  end

  def undecorated_repository
    PolymorphicTermRepository.new(Vocabulary, Term)
  end

  def decorators
    super || NullDecorator.new
  end

  private

  def decorating_repository
    DecoratingRepository.new(decorators, undecorated_repository)
  end
end

class NullDecorator
  def new(obj)
    obj
  end
end
