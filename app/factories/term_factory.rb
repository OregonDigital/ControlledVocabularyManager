class TermFactory
  class << self
    def new(*args)
      decorate do
        Term.new(*args)
      end
    end

    def find(*args)
      decorate do
        Term.find(*args)
      end
    end

    def exists?(*args)
      Term.exists?(*args)
    end

    private

    def decorate
      result = PolymorphicTermFactory.call(yield)
      
      TermWithChildren.new(result)
    end
  end
end

class PolymorphicTermFactory < Struct.new(:object)
  def self.call(object)
    new(object).build
  end

  def build
    if object.vocabulary?
      return vocabulary_object
    end
    object
  end

  private

  def vocabulary_object
    return find_vocabulary if object.persisted?
    Vocabulary.new << object
  end

  def find_vocabulary
    Vocabulary.find(object.id)
  end
end
