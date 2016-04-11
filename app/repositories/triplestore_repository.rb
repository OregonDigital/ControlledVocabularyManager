# an ActiveTriples repository
class TriplestoreRepository
  attr_reader :triplestore, :rdf_statement, :url

  def initialize(rdf_statement, type, url)
    @rdf_statement ||= rdf_statement
    @url = url
    client = TriplestoreAdapter::Client.new(type, url)
    @triplestore = TriplestoreAdapter::Triplestore.new(client)
  end

  def query(*args)
    statements
  end

  # Inserting the statements related to the model posted from the form
  def <<(model)
    @triplestore.store(model.each_statement.to_a)
  end

  # Repository pattern suggests that when updating a term, delete occurs prior
  # to inserting (<<) the model posted from the form
  def delete(*args)
    if args.is_a?(Array)
      url = args.flatten.first.scheme + "://" + args.flatten.first.host + args.flatten.first.path
      @triplestore.delete(url)
    else
      @triplestore.delete(*args)
    end
  end

  def clear_statements
    @triplestore.delete_statements
  end

  def build_namespace
    @triplestore.client.build_namespace(Rails.env.downcase)
  end

  def delete_namespace
    raise "No deleting the production namespace!" if Rails.env.downcase == 'production'
    @triplestore.client.delete_namespace(Rails.env.downcase)
  end

  # get an enumerable of the statements related to the rdf_statement
  def statements
    begin
      subject = @rdf_statement.subject.to_s 
      @triplestore.fetch(subject)
    rescue TriplestoreAdapter::TriplestoreException => e
      puts "[ERROR] TriplestoreRepository.statements failed with TriplestoreException: #{e.message}"
      RDF::Graph.new
    rescue => e
      puts "[ERROR] TriplestoreRepository.statements failed with exception: #{e.message}"
      RDF::Graph.new
    end
  end
end
