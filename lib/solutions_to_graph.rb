# frozen_string_literal: true

class SolutionsToGraph < Struct.new(:solutions)
  def graph
    g = RDF::Graph.new
    g.insert(*triples)
    g
  end

  private

  def triples
    solutions.map{ |x| to_triple(x) }
  end

  def to_triple(solution)
    hsh = solution.to_hash
    RDF::Statement.from([hsh[:s], hsh[:p], hsh[:o]])
  end

end

