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
    if predicate_form.save
      triples = predicate_form.sort_stringify(predicate_form.single_graph)
      rugged_create(predicate_params[:id], triples, "creating")
      rugged_merge(predicate_params[:id])

      redirect_to term_path(:id => predicate_form.id)
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
    if edit_predicate_form.save
      triples = edit_predicate_form.sort_stringify(edit_predicate_form.single_graph)
      rugged_create(params[:id], triples, "updating")
      rugged_merge(params[:id])

      redirect_to term_path(:id => params[:id])
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
    if edit_predicate_form.save
      redirect_to term_path(:id => params[:id])
    else
      @term = edit_predicate_form
      render "deprecate"
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
