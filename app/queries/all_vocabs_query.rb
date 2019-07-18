# frozen_string_literal: true

# All Vocabs Query
class AllVocabsQuery < Struct.new(:sparql_client, :repository, :term_type)
  class << self
    def call(sparql_client, repository, term_type)
      new(sparql_client, repository, term_type).all
    end
  end

  def all
    GraphToTerms.new(repository, all_vocabs_graph).terms
  end

  private

  def all_vocabs_graph
    AllVocabsGraph.new(sparql_client, term_type).graph
  end
end

# All Vocabs Graph
class AllVocabsGraph < Struct.new(:sparql_client, :term_type)
  def graph
    SubjectsToGraph.new(sparql_client, statements).graph
  end

  private

  def statements
    @statements ||= sparql_client.select.where([:s, RDF.type, term_type]).each_solution.map { |x| x[:s] }
  end
end
