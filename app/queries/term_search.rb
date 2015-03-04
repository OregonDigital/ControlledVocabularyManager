class TermSearch
  attr_reader :sparql_client, :query

  def initialize(sparql_client)
    @sparql_client = sparql_client
  end

  def search(query)
    @query = query
    terms
  end

  private

  def terms
    GraphToTerms.new(PolymorphicTermRepository, graph).run
  end

  def graph
    SubjectsToGraph.new(sparql_client, subjects).graph
  end

  def subjects
    sparql_client.select.where([:s, :p, :o]).filter("contains(?o, \"#{query}\")").each_solution.map{|x| x[:s]}
  end
end
