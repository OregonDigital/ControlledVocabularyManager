class PolymorphicTermRepository < Struct.new(:id)
  class << self
    alias_method :orig_new, :new
    def new(*args)
      orig_new(*args).build
    end

    def find(*args)
      orig_new(*args).find
    end
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
