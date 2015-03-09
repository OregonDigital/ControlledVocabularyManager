class PolymorphicTermRepository
  attr_reader :vocabulary_repository, :term_repository, :id

  def initialize(vocabulary_repository, term_repository)
    @vocabulary_repository = vocabulary_repository
    @term_repository = term_repository
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
    term_id = TermID.new(id)
    if term_id.vocabulary?
      vocabulary_repository
    else
      term_repository
    end
  end

end
