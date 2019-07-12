# frozen_string_literal: true

class TermWithoutChildren < SimpleDelegator
  def initialize(resource)
    super(resource)
  end

  def single_graph
    inject(RDF::Graph.new, :<<)
  end

  def sort_stringify(graph)
    triples = graph.statements.to_a.sort_by(&:predicate).inject { |collector, element| collector.to_s + "\n" + element.to_s }
  end
end
