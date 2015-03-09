# Wraps RDF::Graph.load for consistent return: on meaningless data, an empty
# graph is returned, so we do the same when an exception occurs
class RdfLoader
  def self.call(url)
    begin
      RDF::Graph.load(url)
    rescue
      RDF::Graph.new
    end
  end
end
