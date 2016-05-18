class TermWithoutChildren < SimpleDelegator
  attr_reader :node_finder
  def initialize(resource, node_finder)
    @node_finder = node_finder
    super(resource)
  end


  def single_graph
    (self).inject(RDF::Graph.new, :<<)
  end
end
