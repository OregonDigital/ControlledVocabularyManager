# frozen_string_literal: true

require 'rdf_loader'

# Imports RDF from an externally hosted URL, or using a supplied valid string of
# RDF
class RdfImporter
  attr_reader :url, :rdf_string, :errors, :term_list, :validators, :graph

  # intended to initialize with either a valid URL or an rdf string, with
  # appropriate validators that will consider the source of the RDF.
  def initialize(errors, url: nil, rdf_string: nil, validators: [])
    @errors = errors
    @url = url
    @rdf_string = rdf_string
    @validators = validators
  end

  # kicks the process into motion;
  # - validate the RDF source
  # - build a graph from the source RDF
  # - convert the graph to a list of appropriate terms, which performs the
  # process of inserting the terms into the backend triplestore
  # - finally, return the terms that were stored
  def run
    validators.each { |v| v.new.validate(self) }
    return if errors.any?

    build_graph
    return if errors.any?

    build_term_list
    term_list
  end

  private

  def build_graph
    if @rdf_string.blank?
      @graph = RdfLoader.load_url(@url)
      if @graph.empty?
        errors.add(:url, 'must resolve to valid RDF')
        errors.add(:base, 'URL is not valid.')
      end
    else
      @graph = RdfLoader.load_string(@rdf_string)
      if @graph.empty?
        errors.add(:rdf_string, 'invalid RDF')
        errors.add(:base, 'Text contains invalid RDF.')
      end
    end
  end

  def build_term_list
    @term_list = GraphToImportableTermList.new(@graph).run
    ErrorPropagator.new(term_list, errors, 10).run
  end
end
