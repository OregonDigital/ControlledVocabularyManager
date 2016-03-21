class PolymorphicTermRepository
  attr_reader :repository_type

  def initialize(repository_type)
    @repository_type = repository_type
  end

  def new(id)
    repository(id).new(id)
  end

  def find(id)
    repository(id).find(id)
  end

  def exists?(id)
    repository(id).exists?(id)
  end

  private

  def repository(id)
    return repository_type unless repository_type.nil?

    term = Term.find(id)
    if term.vocabulary?
       Vocabulary
    else Term
    end
  end

end
