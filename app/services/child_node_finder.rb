class ChildNodeFinder
  def self.find_children(vocabulary)
    new(vocabulary).children
  end

  attr_reader :vocabulary
  def initialize(vocabulary)
    @vocabulary = vocabulary
  end

  def children
    children_terms
  end

  private

  def children_graph
    ChildQuery.new(sparql_client, vocabulary.rdf_subject).run
  end

  def children_terms
    GraphToTerms.new(children_graph).run
  end

  def sparql_client
    vocabulary.repository.query_client
  end
end

class GraphToTerms < Struct.new(:graph)
  def run
    graph.each_statement.group_by(&:subject).map do |subject, triples|
      build_term(subject, triples)
    end
  end

  private

  def build_term(subject, triples)
    t = Term.new(subject)
    t.insert(*triples)
    t
  end

end

class ChildQuery < Struct.new(:sparql_client, :parent_uri)
  def run
    graph
  end

  private

  def graph
    g = RDF::Graph.new
    g.insert(*triples)
    g
  end

  def solutions
    query.each_solution.to_a
  end

  def query
    sparql_client.select.where([:s, :p, :o]).filter(query_filter)
  end

  def query_filter
    "STRSTARTS(STR(?s), \"#{parent_uri}/\")"
  end

  def triples
    solutions.map{ |x| to_triple(x) }
  end

  def to_triple(solution)
    hsh = solution.to_hash
    RDF::Statement.from([hsh[:s], hsh[:p], hsh[:o]])
  end
end
