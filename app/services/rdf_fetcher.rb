# Retreives a remote RDF file and returns its graph
class RdfFetcher
  class InvalidURI < StandardError; end

  def self.call(url)
    uri = URI.parse(url)
    unless uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
      raise InvalidURI.new("Cannot use <%s> as an RDF URL" % url)
    end

    RDF::Graph.load(url)
  end
end
