class AllVocabsQuery < Struct.new(:sparql_client, :repository, :options)
  class << self
    def call(sparql_client, repository, options={})
      new(sparql_client, repository, options).all
    end
  end

  delegate :subjects, :graph, :to => :all_vocabs_graph

  def all
    GraphToTerms.new(repository, graph).run
  end

  def limit(new_limit)
    self.class.new(sparql_client, repository, options.merge(:limit => new_limit))
  end
  
  def offset(new_offset)
    self.class.new(sparql_client, repository, options.merge(:offset => new_offset))
  end

  def options
    super || {}
  end

  private

  def all_vocabs_graph
    @all_vocabs_graph ||= AllVocabsGraph.new(sparql_client, options_limit, options_offset)
  end

  def options_limit
    options[:limit]
  end

  def options_offset
    options[:offset]
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

  def subjects
    @subjects ||= query.each_solution.map{|x| x[:s]}
  end

  private

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

