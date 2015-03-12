class ChildNodeFinder
  attr_reader :repository, :sparql_client
  def initialize(repository, sparql_client)
    @repository = repository
    @sparql_client = sparql_client
  end

  def find_children(vocabulary)
    query_graph = ChildQuery.new(sparql_client, vocabulary.rdf_subject).run
    GraphToTerms.new(repository, query_graph).run
  end

end


class ChildQuery
  pattr_initialize :sparql_client, :parent_uri

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
