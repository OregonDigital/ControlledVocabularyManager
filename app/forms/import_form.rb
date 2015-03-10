class ImportForm
  include ActiveModel::Model
  attr_accessor :url, :preview

  delegate :url_to_graph, :graph_to_termlist, :to => :injector

  validates_with IsValidRdfImportUrl

  def graph
    @graph ||= build_graph
  end

  def term_list
    @term_list ||= build_term_list
  end

  def preview?
    preview == "1"
  end

  private

  def build_graph
    graph = url_to_graph.call(url)
    if graph.empty?
      errors.add(:url, "must resolve to valid RDF")
    end

    graph
  end

  def build_term_list
    term_list = graph_to_termlist.call(graph)
    unless term_list.valid?
      errorlist = term_list.errors.full_messages
      if errorlist.count > 10
        errorlist = errorlist[0,10] + ["Further errors exist but were suppressed"]
      end
      errorlist.each do |message|
        errors.add(:base, message)
      end
    end

    term_list
  end

  def injector
    @injector ||= ImportFormInjector.new
  end
end
