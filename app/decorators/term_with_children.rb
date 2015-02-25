class TermWithChildren < SimpleDelegator
  def children
    @children ||= ChildNodeFinder.find_children(self)
  end

  def full_graph
    (children << self).inject(RDF::Graph.new, :<<)
  end
end
