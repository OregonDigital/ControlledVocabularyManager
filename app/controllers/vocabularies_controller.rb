class VocabulariesController < ApplicationController
  delegate :vocabulary_form, :edit_vocabulary_form, :all_vocabs_query, :to => :injector
  skip_before_filter :check_auth, :only => [:index]

  def index
    @vocabularies = all_vocabs_query.call
  end

  def new
    @vocabulary = vocabulary_form
  end

  def create
    if vocabulary_form.save
      redirect_to term_path(:id => vocabulary_form.id)
    else
      @vocabulary = vocabulary_form
      render "new"
    end
  end

  def edit
    @term = edit_vocabulary_form
  end

  def update
    if edit_vocabulary_form.save
      redirect_to term_path(:id => params[:id])
    else
      @term = edit_vocabulary_form
      render "edit"
    end
  end

  private

  def injector
    @injector ||= VocabularyInjector.new(params)
  end
end
