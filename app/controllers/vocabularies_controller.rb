class VocabulariesController < AdminController
  delegate :vocabulary_form_repository,  :all_vocabs_query, :to => :injector
  delegate :deprecate_vocabulary_form_repository, :to => :deprecate_injector
  include GitInterface
  def index
    @vocabularies = all_vocabs_query.call
    @vocabularies.sort_by! {|v| v.rdf_label.first.downcase }
  end

  def new
    @vocabulary = vocabulary_form_repository.new
  end

  def create
    vocabulary_form = vocabulary_form_repository.new(vocabulary_params[:id])
    vocabulary_form.attributes = vocabulary_params.except(:id)
    vocabulary_form.set_languages(params[:vocabulary])
    if vocabulary_form.save
      triples = vocabulary_form.sort_stringify(vocabulary_form.single_graph)
      rugged_create(vocabulary_params[:id], triples, "creating")
      rugged_merge(vocabulary_params[:id])

      redirect_to term_path(:id => vocabulary_form.id)
    else
      @vocabulary = vocabulary_form
      render "new"
    end
  end

  def deprecate
    @term = vocabulary_form_repository.find(params[:id])
  end

  def edit
    @term = vocabulary_form_repository.find(params[:id])
  end

  def update
    edit_vocabulary_form = vocabulary_form_repository.find(params[:id])
    edit_vocabulary_form.attributes = vocabulary_params
    edit_vocabulary_form.set_languages(params[:vocabulary])
    if edit_vocabulary_form.save
      triples = edit_vocabulary_form.sort_stringify(edit_vocabulary_form.single_graph)
      rugged_create(params[:id], triples, "updating")
      rugged_merge(params[:id])

      redirect_to term_path(:id => params[:id])
    else
      @term = edit_vocabulary_form
      render "edit"
    end
  end

  def deprecate_only
    edit_vocabulary_form = deprecate_vocabulary_form_repository.find(params[:id])
    edit_vocabulary_form.is_replaced_by = vocabulary_params[:is_replaced_by]

    if edit_vocabulary_form.save
      triples = edit_vocabulary_form.sort_stringify(edit_vocabulary_form.single_graph)
      rugged_create(params[:id], triples, "creating")
      rugged_merge(params[:id])

      redirect_to term_path(:id => params[:id])
    else
      @term = edit_vocabulary_form
      render "deprecate"
    end
  end

  private

  def vocabulary_params
    ParamCleaner.call(params[:vocabulary])
  end

  def injector
    @injector ||= VocabularyInjector.new(params)
  end

  def deprecate_injector
    @injector ||= DeprecateVocabularyInjector.new(params)
  end

end
