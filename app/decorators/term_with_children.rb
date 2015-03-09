class TermWithChildren < SimpleDelegator
  attr_reader :node_finder
  def initialize(resource, node_finder)
    @node_finder = node_finder
    super(resource)
  end

  def children
    @children ||= node_finder.find_children(self)
  end

  def full_graph
    (children << self).inject(RDF::Graph.new, :<<)
  end
end
