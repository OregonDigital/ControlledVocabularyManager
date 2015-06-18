class MarmottaRepository
  attr_reader :uri, :connection
  def initialize(uri, connection)
    @uri = uri
    @connection = connection
  end

  def query(*args)
    marmotta_resource.get
  end

  def delete(*args)
    marmotta_resource.delete
  end

  def <<(stuff)
    graph = (RDF::Graph.new << marmotta_resource.get)
    graph << stuff
    marmotta_resource.post(graph)
    true
  end

  def statements
    marmotta_resource.get
  end

  private

  def marmotta_resource
    @marmotta_resource ||= Marmotta::Resource.new(uri, connection: connection)
  end
end
