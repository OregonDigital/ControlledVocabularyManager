require 'json/ld'
require 'rdf'
require 'rdf/ntriples'

# Wraps RDF::Graph.load for consistent return: on meaningless data, an empty
# graph is returned, so we do the same when an exception occurs
class RdfLoader

  ##
  # Use the triplestore adapter to load the graph from an URL into a graph, or an empty graph is fetching failed
  #
  # @param url [String] the URL endpoint of the RDF graph to load
  # @return [RDF::Graph]
  def self.load_url(url)
    begin
      @triplestore = TriplestoreAdapter::Triplestore.new(TriplestoreAdapter::Client.new(Settings.triplestore_adapter.type, Settings.triplestore_adapter.url))
      @triplestore.fetch(url.to_s, from_remote: true)
    rescue TriplestoreAdapter::TriplestoreException => e
      Rails.logger.fatal("RdfLoader.load_url(#{url}) failed with #{e.message}")
      RDF::Graph.new
    rescue => e
      Rails.logger.fatal("RdfLoader.load_url(#{url}) failed with #{e.message}")
      RDF::Graph.new
    end
  end

  ##
  # Load a JSON-LD encoded string into an RDF:Graph, or an empty graph if parsing failed
  #
  # @param string [String] a stringified graph
  # @return [RDF::Graph]
  def self.load_string(string)
    begin
      input = JSON.parse(string)
      graph = RDF::Graph.new << JSON::LD::API.toRdf(input)
      graph
    rescue => e
      Rails.logger.fatal("RdfLoader.load_string(#{string}) failed with #{e.message}")
      RDF::Graph.new
    end
  end

  ##
  # Open a file and return the RDF::Graph, or an empty graph if loading failed
  #
  # @param filename [String] the full path to the RDF file to open
  # @return [RDF::Graph]
  def self.load_file(filename)
    return RDF::Graph.new unless File.exist?(filename)
    begin
      RDF::Graph.load(filename)
    rescue => e
      Rails.logger.fatal("RdfLoader.load_file(#{filename}) failed with #{e.message}")
      RDF::Graph.new
    end
  end
end
