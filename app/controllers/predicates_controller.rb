class PredicatesController < ApplicationController
  delegate :predicate_form_repository, :all_preds_query, :to => :injector
  delegate :deprecate_predicate_form_repository, :to => :deprecate_injector
  include GitInterface
  def index
    @predicates = all_preds_query.call
    @predicates.sort_by! {|v| v[:label]}
  end

  def new
    @predicate = predicate_form_repository.new
  end

  def create
    predicate_form = predicate_form_repository.new(predicate_params[:id])
    predicate_form.attributes = vocabulary_params.except(:id)
    predicate_form.set_languages(params[:vocabulary])
    predicate_form.set_modified
    predicate_form.set_issued
    if predicate_form.is_valid?
      predicate_form.add_resource
      triples = predicate_form.sort_stringify(predicate_form.single_graph)
      rugged_create(predicate_params[:id], predicate_params[:id] + "_branch", triples, "creating")
      flash[:notice] = "#{params[:id]} has been saved and added to the review queue."
      redirect_to "/predicates"

    else
      @predicate = predicate_form
      render "new"
    end
  end

  def edit
    @term = predicate_form_repository.find(params[:id])
  end

  def update
    edit_predicate_form = predicate_form_repository.find(params[:id])
    edit_predicate_form.attributes = vocabulary_params
    edit_predicate_form.set_languages(params[:vocabulary])
    edit_predicate_form.set_modified
    if edit_predicate_form.is_valid?
      triples = edit_predicate_form.sort_stringify(edit_predicate_form.single_graph)
      rugged_create(params[:id], params[:id] + "_branch", triples, "updating")
      flash[:notice] = "Changes to #{params[:id]} have been saved and added to the review queue."
      redirect_to "/predicates"
    else
      @term = edit_predicate_form
      render "edit"
    end
  end

  def deprecate
    @term = predicate_form_repository.find(params[:id])
  end

  def deprecate_only
    edit_predicate_form = deprecate_predicate_form_repository.find(params[:id])
    edit_predicate_form.is_replaced_by = vocabulary_params[:is_replaced_by]
    if edit_predicate_form.is_valid?
      triples = edit_predicate_form.sort_stringify(edit_predicate_form.single_graph)
      rugged_create(params[:id], params[:id] + "_branch", triples, "updating")
      flash[:notice] = "Changes to #{params[:id]} have been saved and added to the review queue." 
      redirect_to "/predicates"

    else
      @term = edit_predicate_form
      render "deprecate"
    end
  end


  def commit
    if Term.exists? params[:id]
      predicate_form = predicate_form_repository.find(params[:id])
      predicate_form.attributes = predicate_params
       action = "edit"
    else
      predicate_form = predicate_form_repository.new(params[:id], Predicate)
      predicate_form.attributes = vocabulary_params.except(:id)
      action = "new"
    end
    predicate_form.set_languages(params[:vocabulary])
    predicate_form.set_modified
    predicate_form.reset_issued(params[:issued])

    if predicate_form.is_valid?
      triples = predicate_form.sort_stringify(predicate_form.single_graph)
      rugged_create(params[:id], params[:id] + "_branch", triples, "updating")
      flash[:notice] = "Changes to #{params[:id]} have been saved and added to the review queue."
      redirect_to review_queue_path
    else
      @predicate = predicate_form
      @term = predicate_form
      render action
    end
  end

  def mark_reviewed
    if Term.exists? params[:id]
      e_params = edit_params(params[:id] + "_branch")
      predicate_form = predicate_form_repository.find(params[:id])
      predicate_form.attributes = ParamCleaner.call(e_params[:vocabulary].reject{|k,v| k==:language})
      predicate_form.set_languages(e_params[:vocabulary])
    else
      @predicate = reassemble(params[:id] + "_branch")
      predicate_form = PredicateForm.new(@predicate, StandardRepository.new(nil, Predicate))
    end
    if predicate_form.save
      rugged_merge(params[:id], params[:id] + "_branch")
      flash[:notice] = "#{params[:id]} has been saved and is ready for use."
      redirect_to review_queue_path
    else
      flash[:notice] = "Something went wrong, and term was not saved."
      redirect_to review_term_path(params[:id])
    end
  end

private

  def predicate_params
    ParamCleaner.call(params[:predicate])
  end

  def vocabulary_params
    ParamCleaner.call(params[:vocabulary])
  end

  def injector
    @injector ||= PredicateInjector.new(params)
  end

  def deprecate_injector
    @injector ||= DeprecatePredicateInjector.new(params)
  end

end
