# Retreives a remote RDF file and returns its graph
class RdfFetcher
  def self.call(url)
    RDF::Graph.load(url)
  end
end
