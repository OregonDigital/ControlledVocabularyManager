class TermWithChildren < SimpleDelegator
  def children
    @children ||= ChildNodeFinder.find_children(self)
  end
end
