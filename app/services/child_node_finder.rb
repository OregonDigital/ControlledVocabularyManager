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

  def children_solutions
    @children_solutions ||= query.each_solution.to_a
  end

  def query
    sparql_client.select.where([:s, :p, :o]).filter(query_filter)
  end

  def query_filter
    "STRSTARTS(STR(?s), \"#{vocabulary.rdf_subject}/\")"
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
