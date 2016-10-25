class VocabulariesController < AdminController
  delegate :vocabulary_form_repository,  :all_vocabs_query, :to => :injector
  delegate :deprecate_vocabulary_form_repository, :to => :deprecate_injector
  include GitInterface
  def index
    @vocabularies = all_vocabs_query.call
    @vocabularies.sort_by! {|v| v.rdf_label.first.to_s.downcase }
  end

  def new
    @vocabulary = vocabulary_form_repository.new
  end

  def create
    vocabulary_form = vocabulary_form_repository.new(vocabulary_params[:id])
    vocabulary_form.attributes = vocabulary_params.except(:id)
    vocabulary_form.set_languages(params[:vocabulary])
    vocabulary_form.set_modified
    vocabulary_form.set_issued
    if vocabulary_form.is_valid?
      vocabulary_form.add_resource
      triples = vocabulary_form.sort_stringify(vocabulary_form.single_graph)
      check = rugged_create(vocabulary_params[:id], triples, "creating")
      if check
        flash[:notice] = "#{vocabulary_params[:id]} has been saved and added to the review queue"
      else
        flash[:notice] = "Something went wrong, please notify a systems administrator."
      end
      redirect_to "/vocabularies"

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
    edit_vocabulary_form.set_modified
    if edit_vocabulary_form.is_valid?
      triples = edit_vocabulary_form.sort_stringify(edit_vocabulary_form.single_graph)
      check = rugged_create(params[:id], triples, "updating")
      if check
        flash[:notice] = "Changes to #{params[:id]} have been saved and added to the review queue."
      else
        flash[:notice] = "Something went wrong, please notify a systems administrator."
      end
      redirect_to "/vocabularies"
    else
      @term = edit_vocabulary_form
      render "edit"
    end
  end

  def review_update
    if Term.exists? params[:id]
      vocabulary_form = vocabulary_form_repository.find(params[:id])
      vocabulary_form.attributes = vocabulary_params.except(:issued)
      action = "edit"
    else
      vocabulary_form = vocabulary_form_repository.new(params[:id], Vocabulary)
      vocabulary_form.attributes = vocabulary_params.except(:id, :issued)
      vocabulary_form.add_resource
      action = "new"
    end
    vocabulary_form.set_languages(params[:vocabulary])
    vocabulary_form.set_modified
    vocabulary_form.reset_issued(params[:issued])

    if vocabulary_form.is_valid?
      triples = vocabulary_form.sort_stringify(vocabulary_form.single_graph)
      check = rugged_create(params[:id], triples, "updating")
      if check
        flash[:notice] = "Changes to #{params[:id]} have been saved and added to the review queue."
      else
        flash[:notice] = "Something went wrong, please notify a systems administrator."
      end
      redirect_to review_queue_path
    else
      @vocabulary = vocabulary_form
      @term = vocabulary_form
      render action
    end
  end

  def mark_reviewed
    if Term.exists? params[:id]
      e_params = edit_params(params[:id])
      vocabulary_form = vocabulary_form_repository.find(params[:id])
      vocabulary_form.attributes = ParamCleaner.call(e_params[:vocabulary].reject{|k,v| k==:language})
      vocabulary_form.set_languages(e_params[:vocabulary])
    else
      @vocabulary = reassemble(params[:id])
      vocabulary_form = VocabularyForm.new(@vocabulary, StandardRepository.new(nil, Vocabulary))
    end
    branch_commit = rugged_merge(params[:id])
    if branch_commit != 0
      if vocabulary_form.save
        expire_page controller: 'terms', action: 'show', id: params[:id], format: :html
        expire_page controller: 'terms', action: 'show', id: params[:id], format: :jsonld
        expire_page controller: 'terms', action: 'show', id: params[:id], format: :nt
        rugged_delete_branch(params[:id])
        flash[:notice] = "#{params[:id]} has been saved and is ready for use."
        redirect_to review_queue_path
      else
        rugged_rollback(branch_commit)
        flash[:notice] = "Something went wrong, and term was not saved."
        redirect_to review_queue_path
      end
    else
      flash[:notice] = "Something went wrong. Please a systems administrator"
      redirect_to review_queue_path
    end
  end


 def deprecate_only
    edit_vocabulary_form = deprecate_vocabulary_form_repository.find(params[:id])
    edit_vocabulary_form.is_replaced_by = vocabulary_params[:is_replaced_by]

    if edit_vocabulary_form.is_valid?
      triples = edit_vocabulary_form.sort_stringify(edit_vocabulary_form.single_graph)
      check = rugged_create(params[:id], triples, "updating")
      if check
        flash[:notice] = "Changes to #{params[:id]} have been saved and added to the review queue."
      else
        flash[:notice] = "Something went wrong, please notify a systems administrator."
      end
      redirect_to "/vocabularies"
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
