class TermFactory
  class << self
    def new(*args)
      decorate do
        PolymorphicTermRepository.new(*args).build
      end
    end

    def find(*args)
      decorate do
        PolymorphicTermRepository.find(*args)
      end
    end

    def exists?(*args)
      Term.exists?(*args)
    end

    private

    def decorate
      result = yield
      
      TermWithChildren.new(result)
    end
  end
end

class PolymorphicTermRepository < Struct.new(:id)
  def self.find(id)
    new(id).find
  end

  def build
    repository.new(id)
  end

  def find
    repository.find(id)
  end

  private

  def repository
    return vocabulary_repository unless id.include?("/")
    term_repository
  end

  def vocabulary_repository
    Vocabulary
  end

  def term_repository
    Term
  end

end
