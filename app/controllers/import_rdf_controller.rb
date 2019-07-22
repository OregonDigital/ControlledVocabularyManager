# frozen_string_literal: true

# Import RDF Controller
class ImportRdfController < AdminController
  delegate :form_factory, :rdf_importer_factory, :param_cleaner, :form_key, to: :injector
  before_filter :require_admin
  include GitInterface

  def index
    @form = ImportForm.new(*form_params)
  end

  def import
    @form = ImportForm.new(*form_params)
    unless @form.valid?
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

    check = add_to_repo_and_persist(@form.term_list)
    unless check
      render :index
      return
    end

    flash[:success] = 'Imported external RDF resource(s)'
    redirect_to term_path(@form.term_list.terms.first.id)
  end

  # load_rdf process takes in the text of the RDF to import into the triplestore
  def load
    @form = LoadForm.new(*load_form_params)
  end

  # save to the triplestore
  def save
    @form = LoadForm.new(*load_form_params)
    unless @form.valid?
      render :load
      return
    end

    check = add_to_repo_and_persist(@form.term_list)
    unless check
      render :load
      return
    end

    flash[:success] = 'Loaded RDF resource(s)'
    redirect_to term_path(@form.term_list.terms.first.id)
  end

  private

  def add_to_repo_and_persist(term_list)
    term_list.terms.each do |term|
      triples = term.sort_stringify(term)
      check = rugged_create(term.id, triples, 'create')
      unless check
        flash[:error] = "Something went wrong with creating #{term.id}."
        return false
      end
      branch_commit = rugged_merge(term.id)
      unless branch_commit
        flash[:error] = "Something went wrong with merging #{term.id}."
        return false
      end
      unless term.persist!
        rugged_rollback(branch_commit)
        flash[:error] = "Something went wrong with saving #{term.id}."
        return false
      end
      PreloadCache.preload(term)
      rugged_delete_branch(term.id)
    end
    true
  end

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
