class RdfImporter
  attr_reader :url, :errors, :term_list
  delegate :url_to_graph, :graph_to_termlist, :validators, :error_propagator, :to => :injector

  def initialize(errors, url)
    @errors = errors
    @url = url
  end

  def run
    validators.each {|v| v.new.validate(self)}
    build_graph
    build_term_list
    @term_list
  end

  private

  def build_graph
    return if errors.any?

    @graph = url_to_graph.call(url)
    if @graph.empty?
      errors.add(:url, "must resolve to valid RDF")
    end
  end

  def build_term_list
    return if errors.any?

    @term_list = graph_to_termlist.new(@graph).run
    error_propagator.new(@term_list, errors, 10).run
  end

  def injector
    @injector ||= RdfImporterInjector.new
  end
end
