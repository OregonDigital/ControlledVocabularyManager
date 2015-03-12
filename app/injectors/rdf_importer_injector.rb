class RdfImporterInjector
  def url_to_graph
    RdfLoader
  end

  def graph_to_termlist
    GraphToImportableTermList
  end

  def error_propagator
    ErrorPropagator
  end

  def validators
    [IsValidRdfImportUrl]
  end
end
