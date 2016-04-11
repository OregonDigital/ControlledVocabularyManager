class ChildNodeFinder
  attr_reader :sparql_client
  def initialize(sparql_client)
    @sparql_client = sparql_client
  end

  def find_children(vocabulary)
    query_graph = ChildQuery.new(sparql_client, vocabulary.rdf_subject).run
    results = GraphToTerms.new(nil, query_graph).terms
    results.sort_by{|i| i.rdf_subject.to_s.downcase}
  end

end


class ChildQuery < Struct.new(:sparql_client, :parent_uri)
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
    sparql_client.query("SELECT * WHERE { ?s ?p ?o . FILTER(STRSTARTS(STR(?s), \"#{parent_uri}/\")) }")
  end
end
