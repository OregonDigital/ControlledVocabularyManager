class ImportFormInjector
  def url_to_graph
    RdfLoader
  end

  def graph_to_terms
    ->(graph) { GraphToTerms.new(repository, graph).run }
  end

  def graph_to_termlist
    ->(graph) { term_list_factory.new(graph_to_terms.call(graph)) }
  end

  def repository
    DecoratingRepository.new(decorators, polymorphic_repository)
  end

  def polymorphic_repository
    PolymorphicTermRepository.new(Vocabulary, Term)
  end

  def decorators
    DecoratorList.new(SetsModified, SetsIssued)
  end

  def term_list_factory
    ImportableTermList
  end
end
