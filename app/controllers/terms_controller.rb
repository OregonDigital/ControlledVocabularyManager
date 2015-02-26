class TermsController < ApplicationController
  before_filter :load_term, :only => [:show, :edit, :update]
  before_filter :vocabulary, :only => :new
  rescue_from ActiveTriples::NotFound, :with => :render_404
  before_filter :authorize, :only => [:new, :create]

  def show
    respond_to do |format|
      format.html
      format.nt { render body: @term.full_graph.dump(:ntriples), :content_type => Mime::NT }
      format.jsonld { render body: @term.full_graph.dump(:jsonld, standard_prefixes: true), :content_type => Mime::JSONLD }
    end
  end

  def new
    @term = Term.new
  end

  def create
    TermCreator.call(term_params, vocabulary, [CreateResponder.new(self)])
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

  def load_term
    @term = TermFactory.find(params[:id])
  end

  def term_params
    ParamCleaner.call(params[:term])
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
