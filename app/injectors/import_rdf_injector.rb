# Injector for various RDF importing dependencies
class ImportRdfInjector
  def url_to_graph
    RdfFetcher
  end

  def form_factory
    ImportForm
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

  def param_cleaner
    ParamCleaner
  end

  def form_key
    form_factory.model_name.param_key
  end
end
