class GraphToTerms < Struct.new(:resource_factory, :graph)
  def run
    graph.each_statement.group_by(&:subject).map do |subject, triples|
      build_term(subject, triples)
    end
  end

  private

  def build_term(subject, triples)
    t = resource_factory.new(subject)
    t.insert(*triples)
    t
  end

end
