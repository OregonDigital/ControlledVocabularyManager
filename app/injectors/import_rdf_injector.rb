# Injector for various RDF importing dependencies
class ImportRdfInjector
  def form_factory
    ImportForm
  end

  def param_cleaner
    ParamCleaner
  end

  def form_key
    form_factory.model_name.param_key
  end
end
