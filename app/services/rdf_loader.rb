require 'json/ld'

# Wraps RDF::Graph.load for consistent return: on meaningless data, an empty
# graph is returned, so we do the same when an exception occurs
class RdfLoader
  def self.load_url(url)
    begin
      RDF::Graph.load(url)
    rescue
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
