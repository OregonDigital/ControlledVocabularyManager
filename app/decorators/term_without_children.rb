class TermWithoutChildren < SimpleDelegator
  attr_reader :node_finder
  def initialize(resource, node_finder)
    @node_finder = node_finder
    super(resource)
  end

  def single_graph
    (self).inject(RDF::Graph.new, :<<)
  end

  def sort_stringify(graph)
    triples = graph.statements.to_a.sort_by{|x| x.predicate}.inject{|collector, element| collector.to_s + " " + element.to_s}
    triples.gsub!(" . ", " .\n")
  end

end
