class AllVocabsQuery < Struct.new(:sparql_client, :repository)
  class << self
    def call(sparql_client, repository)
      new(sparql_client, repository).all
    end
  end

  def all
    GraphToTerms.new(repository, all_vocabs_graph).run
  end

  private

  def all_vocabs_graph
    AllVocabsGraph.new(sparql_client).graph
  end

end

class AllVocabsGraph < Struct.new(:sparql_client)

  def graph
    SubjectsToGraph.new(sparql_client, subjects).graph
  end

  private


  def subjects
    @subjects ||= sparql_client.select.where([:s, RDF.type, Vocabulary.type]).each_solution.map{|x| x[:s]}
  end

end

