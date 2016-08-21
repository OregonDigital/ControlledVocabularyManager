class GraphToTerms < Struct.new(:resource_factory, :graph)
  attr_reader :klass

  def terms
    graph.each_statement.group_by(&:subject).map do |subject, triples|
      type_of_graph(triples)
      t = klass.new(subject)
      t.insert(*triples)
      t
    end
  end

  def type_of_graph(triples)
    # iterate through the objects of each of the triples to determine what
    # type of vocabulary, predicate, or term this graph is representing so
    # that the proper type of repository can be persisted
    @klass = nil
    statements = triples.select { |s| s.predicate == RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type") && s.object !=  RDF::URI("http://www.w3.org/2000/01/rdf-schema#Resource") }
    uris = statements.map { |s| s.object }
    @klass = TermType.class_from_types(uris) unless statements.empty?
  end
end
