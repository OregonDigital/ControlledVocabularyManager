class TermsController < ApplicationController
  before_filter :load_term, :only => [:show, :edit, :update]
  before_filter :vocabulary, :only => :new
  before_filter :load_vocabulary, :only => [:new, :create]
  delegate :term_form, :term_repository, :vocabulary_repository, :to => :injector
  rescue_from ActiveTriples::NotFound, :with => :render_404
  skip_before_filter :check_auth, :only => [:show]

  def show
    respond_to do |format|
      format.html
      format.nt { render body: @term.full_graph.dump(:ntriples), :content_type => Mime::NT }
      format.jsonld { render body: @term.full_graph.dump(:jsonld, standard_prefixes: true), :content_type => Mime::JSONLD }
    end
  end

  def new
    @term = term_form
  end

  def create
    if term_form.save
      redirect_to term_path(:id => term_form.term_id)
    else
      @term = term_form
      render "new"
    end
  end

  def edit
  end

  def update
    @term.attributes = term_params

    if @term.persist! 
      redirect_to term_path(:id => params[:id])
    else
      redirect_to edit_term_path(:id => params[:id])
    end
  end


  private

  def injector
    @injector ||= TermInjector.new(params)
  end

  def load_term
    @term = term_repository.find(params[:id])
  end

  def load_vocabulary
    @vocabulary = vocabulary_repository.find(params[:vocabulary_id])
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => true, :status => 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def vocabulary
    @vocabulary ||= Vocabulary.find(params[:vocabulary_id])
  end

end
