class PolymorphicTermRepository < Struct.new(:id)
  class << self
    alias_method :orig_new, :new
    def new(*args)
      orig_new(*args).build
    end

    def find(*args)
      orig_new(*args).find
    end

    def exists?(*args)
      orig_new(*args).exists?
    end
  end

  def build
    repository.new(id)
  end

  def find
    repository.find(id)
  end

  def exists?
    repository.exists?(id)
  end

  private

  def repository
    if term_id.vocabulary?
      vocabulary_repository
    else
      term_repository
    end
  end

  def term_id
    @term_id ||= TermID.new(id)
  end

  def vocabulary_repository
    Vocabulary
  end

  def term_repository
    Term
  end

end
