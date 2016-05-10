class ImportRdfController < AdminController
  delegate :form_factory, :rdf_importer_factory, :param_cleaner, :form_key, :to => :injector
  before_filter :require_admin
  
  def index
    @form = ImportForm.new(*form_params)
  end

  def import
    @form = ImportForm.new(*form_params)
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

    flash[:success] = "Imported external RDF resource(s)"
    redirect_to term_path(@form.term_list.terms.first.id)
  end

  # load_rdf process takes in the text of the RDF to import into the triplestore
  def load
    @form = LoadForm.new(*load_form_params)
  end

  # save to the triplestore
  def save
    @form = LoadForm.new(*load_form_params)
    unless @form.save
      render :load
      return
    end

    flash[:success] = "Loaded RDF resource(s)"
    redirect_to term_path(@form.term_list.terms.first.id)
  end

  private

  def form_params
    key = ImportForm.model_name.param_key
    params[key] ||= {}
    ParamCleaner.call(params[key]).values_at(:url, :preview) + [RdfImporter]
  end

  def load_form_params
    key = LoadForm.model_name.param_key
    params[key] ||= {}
    ParamCleaner.call(params[key]).values_at(:rdf_string) + [RdfImporter]
  end
end
