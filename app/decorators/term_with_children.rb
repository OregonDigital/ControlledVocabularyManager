# frozen_string_literal: true

class TermWithChildren < SimpleDelegator
  attr_reader :node_finder
  def initialize(resource, node_finder)
    @node_finder = node_finder
    super(resource)
  end

  def children
    @children ||= node_finder.find_children(self)
  end

  def sort_stringify(graph)
    triples = graph.statements.to_a.sort_by(&:predicate).inject { |collector, element| collector.to_s + "\n" + element.to_s }
  end

  def full_graph
    set_term_type
    children.each(&:set_term_type) unless children.empty?
    (children << self).inject(RDF::Graph.new, :<<)
  end
end
