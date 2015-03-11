class RdfImporter
  attr_reader :url, :errors, :term_list
  delegate :url_to_graph, :graph_to_termlist, :validators, :to => :injector

  def initialize(errors)
    @errors = errors
  end

  def call(url)
    reset(url)
    validators.each {|v| v.new.validate(self)}
    build_graph
    build_term_list
  end

  private

  def reset(url)
    @url = url
    @term_list = nil
    @graph = nil
  end

  def build_graph
    return if errors.any?

    @graph = url_to_graph.call(url)
    if @graph.empty?
      errors.add(:url, "must resolve to valid RDF")
    end
  end

  def build_term_list
    return if errors.any?

    @term_list = graph_to_termlist.call(@graph)
    unless @term_list.valid?
      errorlist = @term_list.errors.full_messages
      if errorlist.count > 10
        errorlist = errorlist[0,10] + ["Further errors exist but were suppressed"]
      end
      errorlist.each do |message|
        errors.add(:base, message)
      end
    end
  end

  def injector
    @injector ||= RdfImporterInjector.new
  end
end
