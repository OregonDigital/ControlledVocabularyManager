require 'json/ld'

class ImportRdfController < ApplicationController
  delegate :form_factory, :param_cleaner, :form_key, :to => :injector
  
  def index
    @form = form_factory.new
  end

  def import
    @form = form_factory.new(form_params)
    # HACK - we still have to check validations twice
    unless @form.valid?
      render :index
      return
    end

    # HACK - we have to request the term list before we find out if there were errors
    @form.term_list
    if @form.errors.any?
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

    @form.term_list.save
    flash[:notice] = "Imported external RDF resource(s)"
    redirect_to term_path(@form.term_list.terms.first.id)
  end

  private

  def form_params
    param_cleaner.call(params[form_key])
  end

  def injector
    @injector ||= ImportRdfInjector.new
  end
end
