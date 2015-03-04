class TermSearch
  attr_reader :sparql_client, :repository, :query

  def initialize(sparql_client, repository)
    @sparql_client = sparql_client
    @repository = repository
  end

  def search(query)
    @query = query
    terms
  end

  private

  def terms
    GraphToTerms.new(repository, graph).run
  end

  def graph
    SubjectsToGraph.new(sparql_client, subjects).graph
  end

  def subjects
    sparql_client.select.where([:s, :p, :o]).filter("contains(?o, \"#{query}\")").each_solution.map{|x| x[:s]}
  end
end
