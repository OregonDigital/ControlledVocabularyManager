class VocabulariesController < ApplicationController
  delegate :vocabulary_form_repository,  :all_vocabs_query, :to => :injector
  skip_before_filter :check_auth, :only => [:index]

  def index
    @vocabularies = all_vocabs_query.call
    @vocabularies.sort_by! {|v| v[:label]}
  end

  def new
    @vocabulary = vocabulary_form_repository.new
  end

  def create
    vocabulary_form = vocabulary_form_repository.new(vocabulary_params[:id])
    vocabulary_form.attributes = vocabulary_params.except(:id)
    vocabulary_form.set_languages(params)
    if vocabulary_form.save
      redirect_to term_path(:id => vocabulary_form.id)
    else
      @vocabulary = vocabulary_form
      render "new"
    end
  end

  def edit
    @term = vocabulary_form_repository.find(params[:id])
  end

  def update
    edit_vocabulary_form = vocabulary_form_repository.find(params[:id])
    edit_vocabulary_form.attributes = vocabulary_params
    edit_vocabulary_form.set_languages(params)
    if edit_vocabulary_form.save
      redirect_to term_path(:id => params[:id])
    else
      @term = edit_vocabulary_form
      render "edit"
    end
  end

  private

  def vocabulary_params
    ParamCleaner.call(params[:vocabulary])
  end

  def injector
    @injector ||= VocabularyInjector.new(params)
  end
end
