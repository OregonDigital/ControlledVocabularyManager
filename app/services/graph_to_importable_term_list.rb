class GraphToImportableTermList < Struct.new(:graph)
  attr_accessor :decorators, :repository

  def run
    ImportableTermList.new(terms)
  end

  def repository
    @repository ||= StandardRepository.new(decorators)
  end

  def decorators
    @decorators ||= DecoratorList.new(SetsModified, SetsIssued, SetsAttributes)
  end

  def terms
    @terms ||= GraphToTerms.new(repository, graph).terms
  end
end
