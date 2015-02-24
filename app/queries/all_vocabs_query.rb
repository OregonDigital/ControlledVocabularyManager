class AllVocabsQuery < Struct.new(:sparql_client)
  class << self
    def call(sparql_client)
      new(sparql_client).all
    end
  end

  def all
    GraphToTerms.new(Vocabulary, all_vocabs_graph).run
  end

  private

  def all_vocabs_graph
    AllVocabsGraph.new(sparql_client).graph
  end

end

class AllVocabsGraph < Struct.new(:sparql_client)

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

  def query
    sparql_client.select.where([:s, :p, :o]).filter(filter)
  end

  def filter
    "?s IN (#{subjects_string})"
  end

  def subjects_string
    subjects.map{|x| "<#{x}>"}.join(", ")
  end

  def subjects
    @subjects ||= sparql_client.select.where([:s, RDF.type, Vocabulary.type]).each_solution.map{|x| x[:s]}
  end

  def solutions
    query.each_solution.to_a
  end

end
