class TermWithChildren < SimpleDelegator
  def children
    @children ||= ChildNodeFinder.find_children(self)
  end

  def full_graph
    new_graph = RDF::Graph.new
    new_graph.insert(*statements)
    children.each do |child|
      new_graph.insert(*child.statements)
    end
    new_graph
  end
end
