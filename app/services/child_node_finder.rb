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

  def child_query
    "select DISTINCT * WHERE
    {
      ?s ?p ?o
      FILTER(STRSTARTS(STR(?s), \"#{vocabulary.rdf_subject}/\")) .
    }"
  end

  def children_solutions
    @children_solutions ||= sparql_client.query(child_query)
  end

  def children_triples
    @children_triples ||= children_solutions.map{|x| to_triple(x)}
  end

  def to_triple(solution)
    hsh = solution.to_hash
    RDF::Statement.from([hsh[:s], hsh[:p], hsh[:o]])
  end

  def children_terms
    children_triples.group_by(&:subject).map do |subject, triples|
      t = Term.new(subject)
      t.insert(*triples)
      t
    end
  end

  def sparql_client
    vocabulary.repository.query_client
  end
end
