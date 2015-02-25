class TermsController < ApplicationController
  before_filter :load_term, :only => :show
  before_filter :vocabulary, :only => :new
  rescue_from ActiveTriples::NotFound, :with => :render_404
  before_filter :authorize, :only => [:new, :create]

  def show
    respond_to do |format|
      format.html
      format.nt { render body: @term.dump(:ntriples), :content_type => Mime::NT }
      format.jsonld { render body: @term.dump(:jsonld, standard_prefixes: true), :content_type => Mime::JSONLD }
    end
  end

  def new
    @term = Term.new
  end

  def create
    TermCreator.call(params[:term], vocabulary, [CreateResponder.new(self)])
  end

  private

  def load_term
    @term = TermFactory.find(params[:id])
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

  def authorize
    if session[:authorized] != true
      session[:user_route] = request.env['PATH_INFO']
      redirect_to '/login'
    end
  end
end
