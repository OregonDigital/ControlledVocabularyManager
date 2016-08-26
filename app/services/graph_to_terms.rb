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
    triples.each do |t|
      @klass = TermType.class_from_types([t.object]) if @klass.nil?
    end
  end
end
