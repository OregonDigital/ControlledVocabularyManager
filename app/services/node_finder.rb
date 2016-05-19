class NodeFinder
  attr_reader :repository, :sparql_client
  def initialize(repository, sparql_client)
    @repository = repository
    @sparql_client = sparql_client
  end

  def find_triples(vocabulary)
    query_graph = SingleQuery.new(sparql_client, vocabulary.rdf_subject).run
    results = GraphToTerms.new(repository, query_graph).run
    results.sort_by{|i| i.rdf_subject.to_s.downcase}
  end

end


class SingleQuery < Struct.new(:sparql_client, :uri)
  def run
    graph
  end

  private

  def graph
    @graph ||= SolutionsToGraph.new(solutions).graph
  end

  def solutions
    query.each_solution.to_a
  end

  def query
    sparql_client.select.where([:s, :p, :o]).filter(query_filter)
  end

  def query_filter
    "STRSTARTS(STR(?s), \"#{uri}/\")"
  end

end
