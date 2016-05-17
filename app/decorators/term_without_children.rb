class TermWithoutChildren < SimpleDelegator
  def initialize(resource)
    super(resource)
  end

  def single_graph
    (self).inject(RDF::Graph.new, :<<)
  end

  def sort_stringify(graph)
    graph.statements.to_a.sort_by{|x| x.predicate}.inject{|collector, element| collector.to_s + " " + element.to_s}
  end

end
