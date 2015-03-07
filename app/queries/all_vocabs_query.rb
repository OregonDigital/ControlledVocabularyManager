class AllVocabsQuery < Struct.new(:sparql_client, :repository, :options)
  class << self
    def call(sparql_client, repository, options={})
      new(sparql_client, repository, options).all
    end
  end

  def all
    GraphToTerms.new(repository, all_vocabs_graph).run
  end

  private

  def limit
    options[:limit]
  end
  
  def offset
    options[:offset]
  end

  def all_vocabs_graph
    AllVocabsGraph.new(sparql_client, limit, offset).graph
  end

end

class AllVocabsGraph

  attr_reader :sparql_client, :limit, :offset

  def initialize(sparql_client, limit=nil, offset=nil)
    @sparql_client = sparql_client
    @limit = limit
    @offset = offset
  end

  def graph
    SubjectsToGraph.new(sparql_client, subjects).graph
  end

  private


  def subjects
    @subjects ||= query.each_solution.map{|x| x[:s]}
  end

  def query
    query = select_query
    query = query.limit(limit) if limit
    query = query.offset(offset) if offset
    query
  end

  def select_query
    sparql_client.select.where([:s, RDF.type, Vocabulary.type]).order(:s)
  end

end

