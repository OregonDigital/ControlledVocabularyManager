require 'json/ld'

# Wraps RDF::Graph.load for consistent return: on meaningless data, an empty
# graph is returned, so we do the same when an exception occurs
class RdfLoader

  def self.load_url(url)
    begin
      @triplestore = TriplestoreAdapter::Triplestore.new(TriplestoreAdapter::Client.new(Settings.triplestore_adapter.type, Settings.triplestore_adapter.url))
      @triplestore.fetch(url.to_s, from_remote: true)
    rescue TriplestoreAdapter::TriplestoreException
      RDF::Graph.new
    end
  end
  def self.load_string(string)
    begin
      input = JSON.parse(string)
      graph = RDF::Graph.new << JSON::LD::API.toRdf(input)
      graph
    rescue
      RDF::Graph.new
    end
  end
end
