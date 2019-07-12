# frozen_string_literal: true

require 'json/ld'
require 'rdf'
require 'rdf/ntriples'
require 'rest_client'

# Wraps RDF::Graph.load for consistent return: on meaningless data, an empty
# graph is returned, so we do the same when an exception occurs
class RdfLoader
  ##
  # Fetch content from url and try forming a graph
  #
  # @param url [String] the URL endpoint of the RDF graph to load
  # @return [RDF::Graph]

  def self.load_url(url)
    response = fetch_data(url)
    input = JSON.parse(response)
    graph = RDF::Graph.new << JSON::LD::API.toRdf(input)
    graph
  rescue StandardError => e
    Rails.logger.fatal("RdfLoader.load_url(#{url}) failed with #{e.message}")
    RDF::Graph.new
  end

  ##
  # Load a JSON-LD encoded string into an RDF:Graph, or an empty graph if parsing failed
  #
  # @param string [String] a stringified graph
  # @return [RDF::Graph]
  def self.load_string(string)
    input = JSON.parse(string)
    graph = RDF::Graph.new << JSON::LD::API.toRdf(input)
    graph
  rescue StandardError => e
    Rails.logger.fatal("RdfLoader.load_string(#{string}) failed with #{e.message}")
    RDF::Graph.new
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
    rescue StandardError => e
      Rails.logger.fatal("RdfLoader.load_file(#{filename}) failed with #{e.message}")
      RDF::Graph.new
    end
  end

  private

  def self.fetch_data(url)
    response = RestClient.get url, accept: :json
  end
end
