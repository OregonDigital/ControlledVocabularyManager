class PolymorphicTermRepository

  attr_reader :vocabulary_repository, :term_repository, :id
  delegate :new, :find, :exists?, :to => :repository

  def initialize(vocabulary_repository, term_repository)
    @vocabulary_repository = vocabulary_repository
    @term_repository = term_repository
  end

  def new(id)
    @id = id
    repository.new(id)
  end

  def find(id)
    @id = id
    repository.find(id)
  end

  def exists?(id)
    @id = id
    term_repository.exists?(id)
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
    TermID.new(id)
  end

end
