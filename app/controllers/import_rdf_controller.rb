class ImportRdfController < ApplicationController
  delegate :form_factory, :rdf_importer_factory, :param_cleaner, :form_key, :to => :injector
  
  def index
    @form = form_factory.new(*form_params)
  end

  def import
    @form = form_factory.new(*form_params)
    unless @form.save
      render :index
      return
    end

    # Render preview page if requested
    if @form.preview?
      @terms = @form.term_list.terms
      @vocabulary = @terms.shift
      render :preview_import
      return
    end

    flash[:notice] = "Imported external RDF resource(s)"
    redirect_to term_path(@form.term_list.terms.first.id)
  end

  private

  def form_params
    params[form_key] ||= {}
    param_cleaner.call(params[form_key]).values_at(:url, :preview) + [rdf_importer_factory]
  end

  def injector
    @injector ||= ImportRdfInjector.new
  end
end
