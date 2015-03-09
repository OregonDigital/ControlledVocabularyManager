require 'json/ld'

class ImportRdfController < ApplicationController
  delegate :form_factory, :url_to_graph, :graph_to_termlist, :param_cleaner, :form_key, :to => :injector
  
  def index
    @form = form_factory.new
  end

  # TODO / discussion items:
  # - Wrap form, graph, and term list in a validation composite to check for
  #   errors and merge them at the top level
  # - How do we best handle more complex imports that have multiple vocabs?
  #   (Or do we even worry about that right now?)
  def import
    @form = form_factory.new(form_params)
    unless @form.valid?
      render :index
      return
    end

    graph = url_to_graph.call(@form.url)
    if graph.empty?
      @form.errors.add(:base, "Unable to retrieve valid RDF from URL <%s>" % @form.url)
      render :index
      return
    end

    term_list = graph_to_termlist.call(graph)
    unless term_list.valid?
      errorlist = term_list.errors.full_messages
      if errorlist.count > 10
        errorlist = errorlist[0,10] + ["Further errors exist but were suppressed"]
      end
      errorlist.each do |message|
        @form.errors.add(:base, message)
      end
      render :index
      return
    end

    # Render preview page if requested
    if @form.preview?
      @terms = term_list.terms
      @vocabulary = @terms.shift
      render :preview_import
      return
    end

    term_list.save
    flash[:notice] = "Imported external RDF resource(s)"
    redirect_to term_path(term_list.terms.first.id)
  end

  private

  def form_params
    param_cleaner.call(params[form_key])
  end

  def injector
    @injector ||= ImportRdfInjector.new
  end
end
